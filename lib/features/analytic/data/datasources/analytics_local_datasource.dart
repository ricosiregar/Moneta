import 'package:moneta/core/database/finance_repository.dart';

import '../../../transactions/data/models/feed_item_model.dart';
import '../models/analytics_models.dart';

abstract class AnalyticsLocalDataSource {
  Stream<PeriodSummaryModel> watchSummary(DateTime from, DateTime to,
      {String? walletId});
  Stream<List<CategoryTotalModel>> watchExpenseByCategory(
      DateTime from, DateTime to,
      {String? walletId});
  Stream<List<DailyTotalModel>> watchDaily(DateTime from, DateTime to,
      {String? walletId});
  Future<List<FeedItemModel>> getTransactionsByCategory({
    required DateTime from,
    required DateTime to,
    String? categoryId,
    String? categoryName,
    String? walletId,
  });
}

class AnalyticsLocalDataSourceImpl implements AnalyticsLocalDataSource {
  final FinanceRepository finance;
  AnalyticsLocalDataSourceImpl({required this.finance});

  @override
  Stream<PeriodSummaryModel> watchSummary(DateTime from, DateTime to,
          {String? walletId}) =>
      finance.watchSummary(from, to, walletId: walletId).map((s) =>
          PeriodSummaryModel(
              income: s.income, expense: s.expense, count: s.count));

  @override
  Stream<List<CategoryTotalModel>> watchExpenseByCategory(
          DateTime from, DateTime to,
          {String? walletId}) =>
      finance.watchExpenseByCategory(from, to, walletId: walletId).map(
            (rows) => [
              for (final c in rows)
                CategoryTotalModel(
                  name: c.name,
                  total: c.total,
                  categoryId: c.categoryId,
                  icon: c.icon,
                  count: c.count,
                ),
            ],
          );

  @override
  Stream<List<DailyTotalModel>> watchDaily(DateTime from, DateTime to,
          {String? walletId}) =>
      finance.watchDaily(from, to, walletId: walletId).map(
            (rows) => [
              for (final d in rows)
                DailyTotalModel(date: d.$1, income: d.$2, expense: d.$3),
            ],
          );

  @override
  Future<List<FeedItemModel>> getTransactionsByCategory({
    required DateTime from,
    required DateTime to,
    String? categoryId,
    String? categoryName,
    String? walletId,
  }) async {
    final rows = await finance.getTransactionsByCategory(
      from: from,
      to: to,
      categoryId: categoryId,
      categoryName: categoryName,
      walletId: walletId,
    );
    return [
      for (final i in rows)
        FeedItemModel(
          id: i.id,
          kind: i.kind,
          title: i.title,
          category: i.category,
          iconKey: i.iconKey,
          wallet: i.wallet,
          amount: i.amount,
          date: i.date,
          walletId: i.walletId,
          toWalletId: i.toWalletId,
          categoryId: i.categoryId,
        ),
    ];
  }
}
