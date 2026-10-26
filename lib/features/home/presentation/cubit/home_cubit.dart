import 'dart:async';

import 'package:moneta/core/network/error/failures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytic/domain/usecases/analytics_usecases.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/usecases/category_usecases.dart';
import '../../../wallets/domain/usecases/wallet_usecases.dart';
import 'home_state.dart';

/// Data dasar beranda: dompet, kategori pengeluaran, dan ringkasan periode.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required WatchWalletsUseCase watchWallets,
    required WatchCategoriesUseCase watchCategories,
    required WatchSummaryUseCase watchSummary,
  })  : _watchWallets = watchWallets,
        _watchCategories = watchCategories,
        _watchSummary = watchSummary,
        super(const HomeState());

  final WatchWalletsUseCase _watchWallets;
  final WatchCategoriesUseCase _watchCategories;
  final WatchSummaryUseCase _watchSummary;

  final _subs = <StreamSubscription<dynamic>>[];
  final _summarySubs = <StreamSubscription<dynamic>>[];

  void _fail(Failure f) => emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: f.message,
      ));

  void start() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    emit(state.copyWith(status: HomeStatus.loading));
    _subs.add(_watchWallets().listen((r) => r.fold(
          _fail,
          (w) => emit(state.copyWith(
            status: HomeStatus.success,
            wallets: w,
            errorMessage: null,
          )),
        )));
    _subs.add(_watchCategories(CategoryType.expense).listen((r) => r.fold(
          _fail,
          (c) => emit(state.copyWith(expenseCategories: c)),
        )));
    watchSummaries(walletId: null);
  }

  /// Ringkasan hari ini / minggu ini / bulan ini, opsional per dompet.
  void watchSummaries({String? walletId}) {
    for (final s in _summarySubs) {
      s.cancel();
    }
    _summarySubs.clear();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final ranges = [
      (today, today.add(const Duration(days: 1))),
      (weekStart, weekStart.add(const Duration(days: 7))),
      (DateTime(now.year, now.month), DateTime(now.year, now.month + 1)),
    ];
    for (var i = 0; i < ranges.length; i++) {
      _summarySubs.add(
        _watchSummary(ranges[i].$1, ranges[i].$2, walletId: walletId)
            .listen((r) => r.fold(_fail, (s) {
                  final next = [...state.summaries];
                  next[i] = s;
                  emit(state.copyWith(summaries: next));
                })),
      );
    }
  }

  @override
  Future<void> close() {
    for (final s in [..._subs, ..._summarySubs]) {
      s.cancel();
    }
    return super.close();
  }
}
