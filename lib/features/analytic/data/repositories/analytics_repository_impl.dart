import 'package:Moneta/core/network/error/failures.dart';
import 'package:Moneta/core/utils/failure_guard.dart';
import 'package:dartz/dartz.dart';

import '../../../transactions/domain/entities/feed_item_entity.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_local_datasource.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsLocalDataSource localDataSource;
  AnalyticsRepositoryImpl({required this.localDataSource});

  @override
  Stream<Either<Failure, PeriodSummaryEntity>> watchSummary(
    DateTime from,
    DateTime to, {
    String? walletId,
  }) =>
      guardStream(
        localDataSource.watchSummary(from, to, walletId: walletId),
        (m) => m.toEntity(),
      );

  @override
  Stream<Either<Failure, List<CategoryTotalEntity>>> watchExpenseByCategory(
    DateTime from,
    DateTime to, {
    String? walletId,
  }) =>
      guardStream(
        localDataSource.watchExpenseByCategory(from, to, walletId: walletId),
        (rows) => [for (final r in rows) r.toEntity()],
      );

  @override
  Stream<Either<Failure, List<DailyTotalEntity>>> watchDaily(
    DateTime from,
    DateTime to, {
    String? walletId,
  }) =>
      guardStream(
        localDataSource.watchDaily(from, to, walletId: walletId),
        (rows) => [for (final r in rows) r.toEntity()],
      );

  @override
  Future<Either<Failure, List<FeedItemEntity>>> getTransactionsByCategory({
    required DateTime from,
    required DateTime to,
    String? categoryId,
    String? categoryName,
    String? walletId,
  }) =>
      guardLocal(() async => [
            for (final m in await localDataSource.getTransactionsByCategory(
              from: from,
              to: to,
              categoryId: categoryId,
              categoryName: categoryName,
              walletId: walletId,
            ))
              m.toEntity(),
          ]);
}
