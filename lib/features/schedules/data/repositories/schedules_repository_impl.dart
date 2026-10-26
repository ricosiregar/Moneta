import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/failure_guard.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/auto_schedule_entity.dart';
import '../../domain/repositories/schedules_repository.dart';
import '../datasources/schedules_local_datasource.dart';

class SchedulesRepositoryImpl implements SchedulesRepository {
  final SchedulesLocalDataSource localDataSource;
  SchedulesRepositoryImpl({required this.localDataSource});

  @override
  Stream<Either<Failure, List<AutoScheduleEntity>>> watchSchedules() =>
      guardStream(
        localDataSource.watchSchedules(),
        (rows) => [for (final r in rows) r.toEntity()],
      );

  @override
  Future<Either<Failure, String>> saveSchedule({
    String? id,
    required String title,
    required String kind,
    required double amount,
    required int dayOfMonth,
    required String walletId,
    String? toWalletId,
    String? categoryId,
    String? budgetId,
    String? note,
    bool isEnabled = true,
    bool executeNowForCurrentMonth = false,
  }) =>
      guardLocal(() => localDataSource.saveSchedule(
            id: id,
            title: title,
            kind: kind,
            amount: amount,
            dayOfMonth: dayOfMonth,
            walletId: walletId,
            toWalletId: toWalletId,
            categoryId: categoryId,
            budgetId: budgetId,
            note: note,
            isEnabled: isEnabled,
            executeNowForCurrentMonth: executeNowForCurrentMonth,
          ));

  @override
  Future<Either<Failure, void>> toggleSchedule(String id, bool isEnabled) =>
      guardLocal(() => localDataSource.toggleSchedule(id, isEnabled));

  @override
  Future<Either<Failure, void>> deleteSchedule(String id) =>
      guardLocal(() => localDataSource.deleteSchedule(id));

  @override
  Future<Either<Failure, AutoScheduleEntity?>> executeNow(
    String id, {
    bool force = false,
  }) =>
      guardLocal(() async =>
          (await localDataSource.executeNow(id, force: force))?.toEntity());

  @override
  Future<Either<Failure, List<AutoScheduleEntity>>> processDue() =>
      guardLocal(() async => [
            for (final m in await localDataSource.processDue()) m.toEntity(),
          ]);
}
