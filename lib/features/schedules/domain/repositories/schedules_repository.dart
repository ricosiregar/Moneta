import 'package:Moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/auto_schedule_entity.dart';

abstract class SchedulesRepository {
  Stream<Either<Failure, List<AutoScheduleEntity>>> watchSchedules();

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
  });

  Future<Either<Failure, void>> toggleSchedule(String id, bool isEnabled);

  Future<Either<Failure, void>> deleteSchedule(String id);

  /// Null bila saldo kurang atau sudah dieksekusi bulan ini (tanpa [force]).
  Future<Either<Failure, AutoScheduleEntity?>> executeNow(
    String id, {
    bool force = false,
  });

  Future<Either<Failure, List<AutoScheduleEntity>>> processDue();
}
