import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/features/categories/domain/entities/category_entity.dart';
import 'package:moneta/features/categories/domain/repositories/category_repository.dart';
import 'package:moneta/features/categories/domain/usecases/category_usecases.dart';
import 'package:moneta/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:moneta/features/categories/presentation/cubit/categories_state.dart';

import 'support/test_helpers.dart';
import 'package:moneta/core/database/finance_repository.dart';
import 'package:moneta/features/categories/data/datasources/category_local_datasource.dart';
import 'package:moneta/features/categories/data/repositories/category_repository_impl.dart';

class _FailingRepo implements CategoryRepository {
  @override
  Stream<Either<Failure, List<CategoryEntity>>> watchCategories(
          CategoryType? type) =>
      Stream.value(const Left(CacheFailure(message: 'gagal baca')));
  @override
  Future<Either<Failure, CategoryEntity>> addCategory(
          {required String name, required CategoryType type, String? icon}) async =>
      const Left(CacheFailure());
  @override
  Future<Either<Failure, void>> deleteCategory(String id) async =>
      const Left(CacheFailure());
}

void main() {
  group('CategoryEntity', () {
    test('isDefault mengenali kategori bawaan per tipe', () {
      const a = CategoryEntity(
          id: '1', name: ' Makanan ', type: CategoryType.expense);
      const b = CategoryEntity(id: '2', name: 'Gaji', type: CategoryType.expense);
      const c = CategoryEntity(id: '3', name: 'Gaji', type: CategoryType.income);
      expect(a.isDefault, isTrue);
      expect(b.isDefault, isFalse);
      expect(c.isDefault, isTrue);
    });
  });

  group('integrasi data -> domain -> cubit (Drift in-memory)', () {
    test('tambah, tampil, hapus; nama kosong ditolak', () async {
      final db = newTestDb();
      final repo = CategoryRepositoryImpl(
        localDataSource:
            CategoryLocalDataSourceImpl(finance: FinanceRepository(db)),
      );
      final cubit = CategoriesCubit(
        watchCategories: WatchCategoriesUseCase(repo),
        addCategory: AddCategoryUseCase(repo),
        deleteCategory: DeleteCategoryUseCase(repo),
      );
      addTearDown(() async {
        await cubit.close();
        await db.close();
      });

      cubit.watch(CategoryType.expense);
      final empty = await cubit.add(name: '  ', type: CategoryType.expense);
      expect(empty.isLeft(), isTrue);

      final added = await cubit.add(
          name: 'Kopi', type: CategoryType.expense, icon: 'restaurant');
      final cat = added.getOrElse(() => throw StateError('gagal'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.categories.map((e) => e.name), contains('Kopi'));
      expect(cubit.state.status, CategoriesStatus.success);

      // Kategori income tidak tercampur.
      cubit.watch(CategoryType.income);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.categories.map((e) => e.name), isNot(contains('Kopi')));

      cubit.watch(CategoryType.expense);
      await cubit.delete(cat.id);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.categories.map((e) => e.name),
          isNot(contains('Kopi')));
    });

    test('stream gagal -> state failure membawa pesan', () async {
      final repo = _FailingRepo();
      final cubit = CategoriesCubit(
        watchCategories: WatchCategoriesUseCase(repo),
        addCategory: AddCategoryUseCase(repo),
        deleteCategory: DeleteCategoryUseCase(repo),
      );
      addTearDown(cubit.close);
      cubit.watch(CategoryType.expense);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(cubit.state.status, CategoriesStatus.failure);
      expect(cubit.state.errorMessage, 'gagal baca');
    });
  });
}
