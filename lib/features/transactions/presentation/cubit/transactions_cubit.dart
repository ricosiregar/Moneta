import 'dart:async';

import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../categories/domain/usecases/category_usecases.dart';
import '../../../wallets/domain/usecases/wallet_usecases.dart';
import '../../domain/usecases/transaction_usecases.dart';
import 'transactions_state.dart';

/// Daftar aktivitas + daftar dompet & kategori untuk filter, dan hapus item.
class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit({
    required WatchFeedUseCase watchFeed,
    required WatchWalletsUseCase watchWallets,
    required WatchCategoriesUseCase watchCategories,
    required DeleteFeedItemUseCase deleteItem,
  })  : _watchFeed = watchFeed,
        _watchWallets = watchWallets,
        _watchCategories = watchCategories,
        _deleteItem = deleteItem,
        super(const TransactionsState());

  final WatchFeedUseCase _watchFeed;
  final WatchWalletsUseCase _watchWallets;
  final WatchCategoriesUseCase _watchCategories;
  final DeleteFeedItemUseCase _deleteItem;

  final _subs = <StreamSubscription<dynamic>>[];

  void watch() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    emit(state.copyWith(status: TransactionsStatus.loading));

    void fail(Failure f) => emit(state.copyWith(
          status: TransactionsStatus.failure,
          errorMessage: f.message,
        ));

    _subs.add(_watchFeed().listen((r) => r.fold(
          fail,
          (items) => emit(state.copyWith(
            status: TransactionsStatus.success,
            items: items,
            errorMessage: null,
          )),
        )));
    _subs.add(_watchWallets().listen((r) => r.fold(
          fail,
          (wallets) => emit(state.copyWith(wallets: wallets)),
        )));
    _subs.add(_watchCategories().listen((r) => r.fold(
          fail,
          (cats) => emit(state.copyWith(categories: cats)),
        )));
  }

  Future<Either<Failure, void>> delete(String id, {required bool isTransfer}) =>
      _deleteItem(DeleteFeedItemParams(id, isTransfer: isTransfer));

  @override
  Future<void> close() {
    for (final s in _subs) {
      s.cancel();
    }
    return super.close();
  }
}
