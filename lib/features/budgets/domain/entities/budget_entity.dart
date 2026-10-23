import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_entity.freezed.dart';

/// Anggaran bulanan satu kategori (atau umum bila [categoryId] null).
@freezed
abstract class BudgetEntity with _$BudgetEntity {
  const factory BudgetEntity({
    required String id,
    String? categoryId,
    required String categoryName,
    required double limit,
    required double spent,
  }) = _BudgetEntity;
}
