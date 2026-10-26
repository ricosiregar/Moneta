import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/category_entity.dart';

/// Kontrak repository kategori.
abstract class CategoryRepository {
  /// Daftar kategori aktif bertipe [type], diperbarui otomatis saat berubah.
  /// [type] null = semua jenis.
  Stream<Either<Failure, List<CategoryEntity>>> watchCategories(
    CategoryType? type,
  );

  Future<Either<Failure, CategoryEntity>> addCategory({
    required String name,
    required CategoryType type,
    String? icon,
  });

  Future<Either<Failure, void>> deleteCategory(String id);
}
