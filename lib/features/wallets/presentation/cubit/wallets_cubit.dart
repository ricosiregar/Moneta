import 'dart:async';

import 'package:Moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/allocation_entity.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/usecases/wallet_usecases.dart';
import 'wallets_state.dart';

/// Daftar dompet + operasi simpan/hapus, alokasi, dan transfer.
class WalletsCubit extends Cubit<WalletsState> {
  WalletsCubit({
    required WatchWalletsUseCase watchWallets,
    required GetAllocationsUseCase getAllocations,
    required SaveWalletUseCase saveWallet,
    required DeleteWalletUseCase deleteWallet,
    required SaveAllocationsUseCase saveAllocations,
    required CreateTransferUseCase createTransfer,
  })  : _watchWallets = watchWallets,
        _getAllocations = getAllocations,
        _saveWallet = saveWallet,
        _deleteWallet = deleteWallet,
        _saveAllocations = saveAllocations,
        _createTransfer = createTransfer,
        super(const WalletsState());

  final WatchWalletsUseCase _watchWallets;
  final GetAllocationsUseCase _getAllocations;
  final SaveWalletUseCase _saveWallet;
  final DeleteWalletUseCase _deleteWallet;
  final SaveAllocationsUseCase _saveAllocations;
  final CreateTransferUseCase _createTransfer;

  StreamSubscription<Either<Failure, List<WalletEntity>>>? _sub;

  void watch() {
    _sub?.cancel();
    emit(state.copyWith(status: WalletsStatus.loading));
    _sub = _watchWallets().listen((result) {
      result.fold(
        (f) => emit(state.copyWith(
          status: WalletsStatus.failure,
          errorMessage: f.message,
        )),
        (list) => emit(state.copyWith(
          status: WalletsStatus.success,
          wallets: list,
          errorMessage: null,
        )),
      );
    });
  }

  Future<Either<Failure, List<AllocationEntity>>> allocations(
    String sourceWalletId,
  ) =>
      _getAllocations(sourceWalletId);

  Future<Either<Failure, void>> save(SaveWalletParams params) =>
      _saveWallet(params);

  Future<Either<Failure, void>> delete(String id) => _deleteWallet(id);

  Future<Either<Failure, void>> saveAllocations(
    SaveAllocationsParams params,
  ) =>
      _saveAllocations(params);

  Future<Either<Failure, void>> transfer(CreateTransferParams params) =>
      _createTransfer(params);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
