import 'package:freezed_annotation/freezed_annotation.dart';

part 'auto_schedule_entity.freezed.dart';

/// Jadwal otomatis bulanan: pembayaran (expense) atau auto-transfer.
@freezed
abstract class AutoScheduleEntity with _$AutoScheduleEntity {
  const AutoScheduleEntity._();

  const factory AutoScheduleEntity({
    required String id,
    required String title,
    required String kind, // 'expense' | 'transfer'
    required double amount,
    required int dayOfMonth, // 1..31
    required String walletId,
    required String walletName,
    String? toWalletId,
    String? toWalletName,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? budgetId,
    String? note,
    required bool isEnabled,
    String? lastExecutedPeriod, // 'YYYY-MM' atau 'SKIP:YYYY-MM'
    DateTime? lastExecutedAt,
  }) = _AutoScheduleEntity;

  static String periodKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  bool get isTransfer => kind == 'transfer';

  bool isExecutedForMonth(DateTime now) => lastExecutedPeriod == periodKey(now);

  bool isSkippedForMonth(DateTime now) =>
      lastExecutedPeriod == 'SKIP:${periodKey(now)}';

  int effectiveDayInMonth(DateTime now) {
    final maxDays = DateTime(now.year, now.month + 1, 0).day;
    return dayOfMonth.clamp(1, maxDays);
  }

  DateTime nextExecutionDate(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final thisMonthDate =
        DateTime(now.year, now.month, effectiveDayInMonth(now));
    if (!isExecutedForMonth(now) &&
        !isSkippedForMonth(now) &&
        !thisMonthDate.isBefore(today)) {
      return thisMonthDate;
    }
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final nextMonthMax = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
    return DateTime(
      nextMonth.year,
      nextMonth.month,
      dayOfMonth.clamp(1, nextMonthMax),
    );
  }
}
