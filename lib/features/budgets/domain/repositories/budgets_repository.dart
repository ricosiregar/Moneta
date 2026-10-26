import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/budget_entity.dart';

abstract class BudgetsRepository {
  Stream<Either<Failure, List<BudgetEntity>>> watchBudgets(int month, int year);

  Future<Either<Failure, String>> saveBudget({
    String? id,
    String? categoryId,
    required double limit,
    required int month,
    required int year,
  });

  Future<Either<Failure, void>> deleteBudget(String id);
}
