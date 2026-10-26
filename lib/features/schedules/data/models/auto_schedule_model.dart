import 'package:moneta/core/database/finance_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auto_schedule_entity.dart';

part 'auto_schedule_model.freezed.dart';

@freezed
abstract class AutoScheduleModel with _$AutoScheduleModel {
  const AutoScheduleModel._();

  const factory AutoScheduleModel({
    required String id,
    required String title,
    required String kind,
    required double amount,
    required int dayOfMonth,
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
    String? lastExecutedPeriod,
    DateTime? lastExecutedAt,
  }) = _AutoScheduleModel;

  factory AutoScheduleModel.fromView(AutoScheduleView s) => AutoScheduleModel(
        id: s.id,
        title: s.title,
        kind: s.kind,
        amount: s.amount,
        dayOfMonth: s.dayOfMonth,
        walletId: s.walletId,
        walletName: s.walletName,
        toWalletId: s.toWalletId,
        toWalletName: s.toWalletName,
        categoryId: s.categoryId,
        categoryName: s.categoryName,
        categoryIcon: s.categoryIcon,
        budgetId: s.budgetId,
        note: s.note,
        isEnabled: s.isEnabled,
        lastExecutedPeriod: s.lastExecutedPeriod,
        lastExecutedAt: s.lastExecutedAt,
      );

  AutoScheduleEntity toEntity() => AutoScheduleEntity(
        id: id,
        title: title,
        kind: kind,
        amount: amount,
        dayOfMonth: dayOfMonth,
        walletId: walletId,
        walletName: walletName,
        toWalletId: toWalletId,
        toWalletName: toWalletName,
        categoryId: categoryId,
        categoryName: categoryName,
        categoryIcon: categoryIcon,
        budgetId: budgetId,
        note: note,
        isEnabled: isEnabled,
        lastExecutedPeriod: lastExecutedPeriod,
        lastExecutedAt: lastExecutedAt,
      );
}
