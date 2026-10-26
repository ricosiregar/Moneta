import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/failure_guard.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budgets_repository.dart';
import '../datasources/budgets_local_datasource.dart';

class BudgetsRepositoryImpl implements BudgetsRepository {
  final BudgetsLocalDataSource localDataSource;
  BudgetsRepositoryImpl({required this.localDataSource});

  @override
  Stream<Either<Failure, List<BudgetEntity>>> watchBudgets(
          int month, int year) =>
      guardStream(
        localDataSource.watchBudgets(month, year),
        (rows) => [for (final r in rows) r.toEntity()],
      );

  @override
  Future<Either<Failure, String>> saveBudget({
    String? id,
    String? categoryId,
    required double limit,
    required int month,
    required int year,
  }) =>
      guardLocal(() => localDataSource.saveBudget(
            id: id,
            categoryId: categoryId,
            limit: limit,
            month: month,
            year: year,
          ));

  @override
  Future<Either<Failure, void>> deleteBudget(String id) =>
      guardLocal(() => localDataSource.deleteBudget(id));
}
