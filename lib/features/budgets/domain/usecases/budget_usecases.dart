import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/budget_entity.dart';
import '../repositories/budgets_repository.dart';

class WatchBudgetsUseCase {
  final BudgetsRepository repository;
  WatchBudgetsUseCase(this.repository);

  Stream<Either<Failure, List<BudgetEntity>>> call(int month, int year) =>
      repository.watchBudgets(month, year);
}

class SaveBudgetParams extends Equatable {
  final String? id;
  final String? categoryId;
  final double limit;
  final int month;
  final int year;

  const SaveBudgetParams({
    this.id,
    this.categoryId,
    required this.limit,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [id, categoryId, limit, month, year];
}

class SaveBudgetUseCase implements UseCase<String, SaveBudgetParams> {
  final BudgetsRepository repository;
  SaveBudgetUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(SaveBudgetParams p) =>
      repository.saveBudget(
        id: p.id,
        categoryId: p.categoryId,
        limit: p.limit,
        month: p.month,
        year: p.year,
      );
}

class DeleteBudgetUseCase implements UseCase<void, String> {
  final BudgetsRepository repository;
  DeleteBudgetUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteBudget(id);
}
