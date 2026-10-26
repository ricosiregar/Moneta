import 'dart:async';

import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/detected_transaction_entity.dart';
import '../../domain/usecases/notification_usecases.dart';
import 'detected_inbox_state.dart';

/// Inbox transaksi terdeteksi: Catat / Abaikan / Pindah dompet.
class DetectedInboxCubit extends Cubit<DetectedInboxState> {
  DetectedInboxCubit({
    required WatchPendingDetectedUseCase watchPending,
    required RecordDetectedUseCase record,
    required IgnoreDetectedUseCase ignore,
    required IgnoreAllDetectedUseCase ignoreAll,
    required ChangeDetectedWalletUseCase changeWallet,
    required ChangeDetectedTypeUseCase changeType,
  })  : _watchPending = watchPending,
        _record = record,
        _ignore = ignore,
        _ignoreAll = ignoreAll,
        _changeWallet = changeWallet,
        _changeType = changeType,
        super(const DetectedInboxState());

  final WatchPendingDetectedUseCase _watchPending;
  final RecordDetectedUseCase _record;
  final IgnoreDetectedUseCase _ignore;
  final IgnoreAllDetectedUseCase _ignoreAll;
  final ChangeDetectedWalletUseCase _changeWallet;
  final ChangeDetectedTypeUseCase _changeType;

  StreamSubscription<Either<Failure, List<DetectedTransactionEntity>>>? _sub;

  void watch() {
    _sub?.cancel();
    emit(state.copyWith(status: DetectedInboxStatus.loading));
    _sub = _watchPending().listen((result) {
      result.fold(
        (f) => emit(state.copyWith(
          status: DetectedInboxStatus.failure,
          errorMessage: f.message,
        )),
        (items) => emit(state.copyWith(
          status: DetectedInboxStatus.success,
          items: items,
          errorMessage: null,
        )),
      );
    });
  }

  Future<Either<Failure, bool>> record(String id) => _record(id);

  Future<Either<Failure, void>> ignore(String id) => _ignore(id);

  Future<Either<Failure, void>> ignoreAll() => _ignoreAll(const NoParams());

  Future<Either<Failure, void>> changeWallet(String id, String walletId) =>
      _changeWallet(ChangeDetectedWalletParams(id, walletId));

  Future<Either<Failure, void>> changeType(String id, String type) =>
      _changeType(ChangeDetectedTypeParams(id, type));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
