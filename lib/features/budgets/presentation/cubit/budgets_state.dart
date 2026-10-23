import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/budget_entity.dart';

part 'budgets_state.freezed.dart';

enum BudgetsStatus { initial, loading, success, failure }

@freezed
abstract class BudgetsState with _$BudgetsState {
  const factory BudgetsState({
    @Default(BudgetsStatus.initial) BudgetsStatus status,
    @Default(<BudgetEntity>[]) List<BudgetEntity> budgets,
    String? errorMessage,
  }) = _BudgetsState;
}
