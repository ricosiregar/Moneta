import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../transactions/domain/entities/feed_item_entity.dart';
import '../entities/analytics_entities.dart';
import '../repositories/analytics_repository.dart';

class WatchSummaryUseCase {
  final AnalyticsRepository repository;
  WatchSummaryUseCase(this.repository);

  Stream<Either<Failure, PeriodSummaryEntity>> call(
    DateTime from,
    DateTime to, {
    String? walletId,
  }) =>
      repository.watchSummary(from, to, walletId: walletId);
}

class WatchExpenseByCategoryUseCase {
  final AnalyticsRepository repository;
  WatchExpenseByCategoryUseCase(this.repository);

  Stream<Either<Failure, List<CategoryTotalEntity>>> call(
    DateTime from,
    DateTime to, {
    String? walletId,
  }) =>
      repository.watchExpenseByCategory(from, to, walletId: walletId);
}

class WatchDailyUseCase {
  final AnalyticsRepository repository;
  WatchDailyUseCase(this.repository);

  Stream<Either<Failure, List<DailyTotalEntity>>> call(
    DateTime from,
    DateTime to, {
    String? walletId,
  }) =>
      repository.watchDaily(from, to, walletId: walletId);
}

class CategoryTransactionsParams extends Equatable {
  final DateTime from;
  final DateTime to;
  final String? categoryId;
  final String? categoryName;
  final String? walletId;

  const CategoryTransactionsParams({
    required this.from,
    required this.to,
    this.categoryId,
    this.categoryName,
    this.walletId,
  });

  @override
  List<Object?> get props => [from, to, categoryId, categoryName, walletId];
}

class GetCategoryTransactionsUseCase
    implements UseCase<List<FeedItemEntity>, CategoryTransactionsParams> {
  final AnalyticsRepository repository;
  GetCategoryTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FeedItemEntity>>> call(
    CategoryTransactionsParams p,
  ) =>
      repository.getTransactionsByCategory(
        from: p.from,
        to: p.to,
        categoryId: p.categoryId,
        categoryName: p.categoryName,
        walletId: p.walletId,
      );
}
