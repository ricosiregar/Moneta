import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../../../transactions/domain/entities/feed_item_entity.dart';
import '../entities/analytics_entities.dart';

abstract class AnalyticsRepository {
  Stream<Either<Failure, PeriodSummaryEntity>> watchSummary(
    DateTime from,
    DateTime to, {
    String? walletId,
  });

  Stream<Either<Failure, List<CategoryTotalEntity>>> watchExpenseByCategory(
    DateTime from,
    DateTime to, {
    String? walletId,
  });

  Stream<Either<Failure, List<DailyTotalEntity>>> watchDaily(
    DateTime from,
    DateTime to, {
    String? walletId,
  });

  Future<Either<Failure, List<FeedItemEntity>>> getTransactionsByCategory({
    required DateTime from,
    required DateTime to,
    String? categoryId,
    String? categoryName,
    String? walletId,
  });
}
