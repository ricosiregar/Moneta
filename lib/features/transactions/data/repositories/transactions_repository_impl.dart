import 'dart:async';

import 'package:moneta/core/database/finance_exception.dart';
import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/app_error_formatter.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/feed_item_entity.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_local_datasource.dart';
import '../models/feed_item_model.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsLocalDataSource localDataSource;

  TransactionsRepositoryImpl({required this.localDataSource});

  Failure _toFailure(Object e) {
    if (e is FinanceException) return ValidationFailure(message: e.message);
    return CacheFailure(message: AppErrorFormatter.format(e));
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Stream<Either<Failure, List<FeedItemEntity>>> watchFeed() =>
      localDataSource.watchFeed().transform(
            StreamTransformer<List<FeedItemModel>,
                Either<Failure, List<FeedItemEntity>>>.fromHandlers(
              handleData: (rows, sink) => sink.add(
                Right([for (final r in rows) r.toEntity()]),
              ),
              handleError: (e, _, sink) => sink.add(Left(_toFailure(e))),
            ),
          );

  @override
  Future<Either<Failure, void>> addTransaction({
    required String walletId,
    String? categoryId,
    required FeedKind kind,
    required double amount,
    String? note,
    DateTime? date,
  }) =>
      _guard(() => localDataSource.addTransaction(
            walletId: walletId,
            categoryId: categoryId,
            type: kind.value,
            amount: amount,
            note: note,
            date: date,
          ));

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) =>
      _guard(() => localDataSource.deleteTransaction(id));

  @override
  Future<Either<Failure, void>> deleteTransfer(String id) =>
      _guard(() => localDataSource.deleteTransfer(id));
}
