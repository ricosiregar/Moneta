import 'dart:async';

import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/budget_usecases.dart';
import 'budgets_state.dart';

/// Anggaran satu bulan: pantau daftar, simpan, hapus.
class BudgetsCubit extends Cubit<BudgetsState> {
  BudgetsCubit({
    required WatchBudgetsUseCase watchBudgets,
    required SaveBudgetUseCase saveBudget,
    required DeleteBudgetUseCase deleteBudget,
  })  : _watch = watchBudgets,
        _save = saveBudget,
        _delete = deleteBudget,
        super(const BudgetsState());

  final WatchBudgetsUseCase _watch;
  final SaveBudgetUseCase _save;
  final DeleteBudgetUseCase _delete;
  StreamSubscription<dynamic>? _sub;

  void watch({required int month, required int year}) {
    _sub?.cancel();
    emit(state.copyWith(status: BudgetsStatus.loading));
    _sub = _watch(month, year).listen((r) => r.fold(
          (f) => emit(state.copyWith(
            status: BudgetsStatus.failure,
            errorMessage: f.message,
          )),
          (b) => emit(state.copyWith(
            status: BudgetsStatus.success,
            budgets: b,
            errorMessage: null,
          )),
        ));
  }

  Future<Either<Failure, String>> save(SaveBudgetParams p) => _save(p);

  Future<Either<Failure, void>> delete(String id) => _delete(id);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
