import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/category_entity.dart';

part 'category_model.freezed.dart';

/// Data model kategori dari database lokal (Drift).
@freezed
abstract class CategoryModel with _$CategoryModel {
  const CategoryModel._();

  const factory CategoryModel({
    required String id,
    required String name,
    required String type,
    String? icon,
  }) = _CategoryModel;

  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        name: name,
        type: CategoryType.fromValue(type),
        icon: icon,
      );
}
