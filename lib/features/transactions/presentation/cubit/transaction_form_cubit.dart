import 'dart:async';

import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../categories/domain/usecases/category_usecases.dart';
import '../../../wallets/domain/usecases/wallet_usecases.dart';
import '../../domain/usecases/transaction_usecases.dart';
import 'transaction_form_state.dart';

/// Form tambah transaksi: pilihan dompet/kategori dan penyimpanan.
class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit({
    required WatchWalletsUseCase watchWallets,
    required WatchCategoriesUseCase watchCategories,
    required AddTransactionUseCase addTransaction,
  })  : _watchWallets = watchWallets,
        _watchCategories = watchCategories,
        _addTransaction = addTransaction,
        super(const TransactionFormState());

  final WatchWalletsUseCase _watchWallets;
  final WatchCategoriesUseCase _watchCategories;
  final AddTransactionUseCase _addTransaction;

  final _subs = <StreamSubscription<dynamic>>[];

  void start() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _subs.add(_watchWallets().listen((r) => r.fold(
          (_) {},
          (wallets) => emit(state.copyWith(wallets: wallets)),
        )));
    _subs.add(_watchCategories().listen((r) => r.fold(
          (_) {},
          (cats) => emit(state.copyWith(categories: cats)),
        )));
  }

  Future<Either<Failure, void>> save(AddTransactionParams params) =>
      _addTransaction(params);

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
