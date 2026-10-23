import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/category_entity.dart';

part 'categories_state.freezed.dart';

enum CategoriesStatus { initial, loading, success, failure }

@freezed
abstract class CategoriesState with _$CategoriesState {
  const CategoriesState._();

  const factory CategoriesState({
    @Default(CategoriesStatus.initial) CategoriesStatus status,
    @Default(CategoryType.expense) CategoryType type,
    @Default(<CategoryEntity>[]) List<CategoryEntity> categories,
    String? errorMessage,
  }) = _CategoriesState;

  bool get isLoading => status == CategoriesStatus.loading;
}
