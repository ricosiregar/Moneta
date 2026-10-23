part of '../finance_repository.dart';

// ── View models ────────────────────────────────────────────────────────────

class CategoryView {
  final String id;
  final String name;
  final String type; // income | expense
  final String? icon;
  const CategoryView(this.id, this.name, this.type, this.icon);
}

class FeedItem {
  final String id;
  final String kind; // income | expense | transfer
  final String title;
  final String category;
  final String? iconKey;
  final String wallet;
  final double amount;
  final DateTime date;
  final String? walletId;
  final String? toWalletId;
  final String? categoryId;
  const FeedItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.category,
    required this.iconKey,
    required this.wallet,
    required this.amount,
    required this.date,
    this.walletId,
    this.toWalletId,
    this.categoryId,
  });
}

class PeriodSummary {
  final double income;
  final double expense;
  final int count;
  const PeriodSummary(this.income, this.expense, this.count);
}

class CategoryTotal {
  final String name;
  final double total;
  final String? categoryId;
  final String? icon;
  final int count;
  const CategoryTotal(
    this.name,
    this.total, {
    this.categoryId,
    this.icon,
    this.count = 0,
  });
}

class BudgetView {
  final String id;
  final String? categoryId;
  final String categoryName;
  final double limit;
  final double spent;
  const BudgetView(
    this.id,
    this.categoryId,
    this.categoryName,
    this.limit,
    this.spent,
  );
}

class JarView {
  final String id;
  final String title;
  final double target;
  final double saved;
  final String? icon;
  final DateTime? targetDate;
  const JarView(
    this.id,
    this.title,
    this.target,
    this.saved,
    this.icon,
    this.targetDate,
  );
}

class AutoScheduleView {
  final String id;
  final String title;
  final String kind; // 'expense' | 'transfer'
  final double amount;
  final int dayOfMonth; // 1..31
  final String walletId;
  final String walletName;
  final String? toWalletId;
  final String? toWalletName;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? budgetId;
  final String? note;
  final bool isEnabled;
  final String? lastExecutedPeriod; // 'YYYY-MM' atau 'SKIP:YYYY-MM'
  final DateTime? lastExecutedAt;

  const AutoScheduleView({
    required this.id,
    required this.title,
    required this.kind,
    required this.amount,
    required this.dayOfMonth,
    required this.walletId,
    required this.walletName,
    this.toWalletId,
    this.toWalletName,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.budgetId,
    this.note,
    required this.isEnabled,
    this.lastExecutedPeriod,
    this.lastExecutedAt,
  });

  static String periodKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  bool isExecutedForMonth(DateTime now) => lastExecutedPeriod == periodKey(now);

  bool isSkippedForMonth(DateTime now) =>
      lastExecutedPeriod == 'SKIP:${periodKey(now)}';

  int effectiveDayInMonth(DateTime now) {
    final maxDays = DateTime(now.year, now.month + 1, 0).day;
    return dayOfMonth.clamp(1, maxDays);
  }

  DateTime nextExecutionDate(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final thisMonthDay = effectiveDayInMonth(now);
    final thisMonthDate = DateTime(now.year, now.month, thisMonthDay);
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
