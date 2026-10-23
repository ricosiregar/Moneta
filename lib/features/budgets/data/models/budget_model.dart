import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/budget_entity.dart';

part 'budget_model.freezed.dart';

@freezed
abstract class BudgetModel with _$BudgetModel {
  const BudgetModel._();

  const factory BudgetModel({
    required String id,
    String? categoryId,
    required String categoryName,
    required double limit,
    required double spent,
  }) = _BudgetModel;

  BudgetEntity toEntity() => BudgetEntity(
        id: id,
        categoryId: categoryId,
        categoryName: categoryName,
        limit: limit,
        spent: spent,
      );
}
