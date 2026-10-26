import 'dart:async';

import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../transactions/domain/entities/feed_item_entity.dart';
import '../../../wallets/domain/usecases/wallet_usecases.dart';
import '../../domain/usecases/analytics_usecases.dart';
import 'analytics_state.dart';

/// Data analitik untuk satu periode + filter dompet.
class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit({
    required WatchWalletsUseCase watchWallets,
    required WatchSummaryUseCase watchSummary,
    required WatchExpenseByCategoryUseCase watchExpenseByCategory,
    required WatchDailyUseCase watchDaily,
    required GetCategoryTransactionsUseCase getCategoryTransactions,
  })  : _watchWallets = watchWallets,
        _watchSummary = watchSummary,
        _watchByCategory = watchExpenseByCategory,
        _watchDaily = watchDaily,
        _getCategoryTx = getCategoryTransactions,
        super(const AnalyticsState());

  final WatchWalletsUseCase _watchWallets;
  final WatchSummaryUseCase _watchSummary;
  final WatchExpenseByCategoryUseCase _watchByCategory;
  final WatchDailyUseCase _watchDaily;
  final GetCategoryTransactionsUseCase _getCategoryTx;

  final _subs = <StreamSubscription<dynamic>>[];

  void _cancel() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }

  /// (Re)bind semua data ke periode [from, to) dan [walletId]; [trendFrom]
  /// untuk grafik tren beberapa bulan.
  void load({
    required DateTime from,
    required DateTime to,
    required DateTime trendFrom,
    String? walletId,
  }) {
    _cancel();
    emit(state.copyWith(status: AnalyticsStatus.loading));

    void fail(Failure f) => emit(state.copyWith(
          status: AnalyticsStatus.failure,
          errorMessage: f.message,
        ));
    AnalyticsState ok(AnalyticsState s) =>
        s.copyWith(status: AnalyticsStatus.success, errorMessage: null);

    _subs.addAll([
      _watchWallets().listen(
          (r) => r.fold(fail, (w) => emit(ok(state.copyWith(wallets: w))))),
      _watchSummary(from, to, walletId: walletId).listen(
          (r) => r.fold(fail, (v) => emit(ok(state.copyWith(summary: v))))),
      _watchByCategory(from, to, walletId: walletId).listen((r) =>
          r.fold(fail, (v) => emit(ok(state.copyWith(categories: v))))),
      _watchDaily(from, to, walletId: walletId).listen(
          (r) => r.fold(fail, (v) => emit(ok(state.copyWith(daily: v))))),
      _watchDaily(trendFrom, to, walletId: walletId).listen(
          (r) => r.fold(fail, (v) => emit(ok(state.copyWith(trend: v))))),
    ]);
  }

  Future<Either<Failure, List<FeedItemEntity>>> categoryTransactions(
    CategoryTransactionsParams p,
  ) =>
      _getCategoryTx(p);

  @override
  Future<void> close() {
    _cancel();
    return super.close();
  }
}
