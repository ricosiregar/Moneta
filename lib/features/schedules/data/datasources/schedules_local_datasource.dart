import 'package:Moneta/core/database/finance_repository.dart';

import '../models/auto_schedule_model.dart';

abstract class SchedulesLocalDataSource {
  Stream<List<AutoScheduleModel>> watchSchedules();
  Future<String> saveSchedule({
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
  Future<void> toggleSchedule(String id, bool isEnabled);
  Future<void> deleteSchedule(String id);
  Future<AutoScheduleModel?> executeNow(String id, {bool force = false});
  Future<List<AutoScheduleModel>> processDue();
}

class SchedulesLocalDataSourceImpl implements SchedulesLocalDataSource {
  final FinanceRepository finance;
  SchedulesLocalDataSourceImpl({required this.finance});

  @override
  Stream<List<AutoScheduleModel>> watchSchedules() =>
      finance.watchAutoSchedules().map(
            (rows) => [for (final s in rows) AutoScheduleModel.fromView(s)],
          );

  @override
  Future<String> saveSchedule({
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
      finance.saveAutoSchedule(
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
      );

  @override
  Future<void> toggleSchedule(String id, bool isEnabled) =>
      finance.toggleAutoSchedule(id, isEnabled);

  @override
  Future<void> deleteSchedule(String id) => finance.deleteAutoSchedule(id);

  @override
  Future<AutoScheduleModel?> executeNow(String id, {bool force = false}) async {
    final r = await finance.executeAutoScheduleNow(id, force: force);
    return r == null ? null : AutoScheduleModel.fromView(r);
  }

  @override
  Future<List<AutoScheduleModel>> processDue() async => [
        for (final s in await finance.processDueAutoSchedules())
          AutoScheduleModel.fromView(s),
      ];
}
