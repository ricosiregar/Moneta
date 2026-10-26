import 'package:moneta/core/database/finance_repository.dart';

import '../models/budget_model.dart';

abstract class BudgetsLocalDataSource {
  Stream<List<BudgetModel>> watchBudgets(int month, int year);
  Future<String> saveBudget({
    String? id,
    String? categoryId,
    required double limit,
    required int month,
    required int year,
  });
  Future<void> deleteBudget(String id);
}

class BudgetsLocalDataSourceImpl implements BudgetsLocalDataSource {
  final FinanceRepository finance;
  BudgetsLocalDataSourceImpl({required this.finance});

  @override
  Stream<List<BudgetModel>> watchBudgets(int month, int year) =>
      finance.watchBudgets(month, year).map((rows) => [
            for (final b in rows)
              BudgetModel(
                id: b.id,
                categoryId: b.categoryId,
                categoryName: b.categoryName,
                limit: b.limit,
                spent: b.spent,
              ),
          ]);

  @override
  Future<String> saveBudget({
    String? id,
    String? categoryId,
    required double limit,
    required int month,
    required int year,
  }) =>
      finance.saveBudget(
        id: id,
        categoryId: categoryId,
        limit: limit,
        month: month,
        year: year,
      );

  @override
  Future<void> deleteBudget(String id) => finance.deleteBudget(id);
}
