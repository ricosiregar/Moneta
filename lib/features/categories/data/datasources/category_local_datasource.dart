import 'package:moneta/core/database/finance_repository.dart';

import '../models/category_model.dart';

/// Sumber data kategori dari database lokal.
abstract class CategoryLocalDataSource {
  Stream<List<CategoryModel>> watchCategories(String? type);

  Future<CategoryModel> addCategory({
    required String name,
    required String type,
    String? icon,
  });

  Future<void> deleteCategory(String id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final FinanceRepository finance;

  CategoryLocalDataSourceImpl({required this.finance});

  CategoryModel _toModel(CategoryView v) =>
      CategoryModel(id: v.id, name: v.name, type: v.type, icon: v.icon);

  @override
  Stream<List<CategoryModel>> watchCategories(String? type) => finance
      .watchCategories(type)
      .map((rows) => [for (final r in rows) _toModel(r)]);

  @override
  Future<CategoryModel> addCategory({
    required String name,
    required String type,
    String? icon,
  }) async =>
      _toModel(await finance.addCategory(name: name, type: type, icon: icon));

  @override
  Future<void> deleteCategory(String id) => finance.deleteCategory(id);
}
