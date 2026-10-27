import 'dart:async';

import 'package:moneta/core/database/finance_exception.dart';
import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/app_error_formatter.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/detected_transaction_entity.dart';
import '../../domain/entities/notification_source_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl({required this.localDataSource});

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

  Stream<Either<Failure, R>> _wrap<S, R>(
    Stream<S> source,
    R Function(S) map,
  ) =>
      source.transform(
        StreamTransformer<S, Either<Failure, R>>.fromHandlers(
          handleData: (data, sink) => sink.add(Right(map(data))),
          handleError: (e, _, sink) => sink.add(Left(_toFailure(e))),
        ),
      );

  @override
  Stream<Either<Failure, List<DetectedTransactionEntity>>> watchPending() =>
      _wrap(localDataSource.watchPending(),
          (rows) => [for (final r in rows) r.toEntity()]);

  @override
  Future<Either<Failure, bool>> record(String id, {String? categoryId}) =>
      _guard(() => localDataSource.record(id, categoryId: categoryId));

  @override
  Future<Either<Failure, void>> ignore(String id) =>
      _guard(() => localDataSource.ignore(id));

  @override
  Future<Either<Failure, void>> ignoreAll() =>
      _guard(() => localDataSource.ignoreAll());

  @override
  Future<Either<Failure, void>> changeWallet(String id, String walletId) =>
      _guard(() => localDataSource.changeWallet(id, walletId));

  @override
  Future<Either<Failure, void>> changeType(String id, String type) =>
      _guard(() => localDataSource.changeType(id, type));

  @override
  Stream<Either<Failure, List<NotificationSourceEntity>>> watchSources() =>
      _wrap(localDataSource.watchSources(),
          (rows) => [for (final r in rows) r.toEntity()]);

  @override
  Future<Either<Failure, void>> upsertSource({
    required String packageName,
    required String walletId,
  }) =>
      _guard(() => localDataSource.upsertSource(
          packageName: packageName, walletId: walletId));

  @override
  Future<Either<Failure, void>> setSourceEnabled(String id, bool enabled) =>
      _guard(() => localDataSource.setSourceEnabled(id, enabled));

  @override
  Future<Either<Failure, void>> deleteSource(String id) =>
      _guard(() => localDataSource.deleteSource(id));

  @override
  Stream<Either<Failure, bool>> watchCaptureEnabled() =>
      _wrap(localDataSource.watchCaptureEnabled(), (v) => v);

  @override
  Future<Either<Failure, void>> setCaptureEnabled(bool enabled) =>
      _guard(() => localDataSource.setCaptureEnabled(enabled));
}
