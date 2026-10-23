import 'dart:async';

import 'package:Moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/category_usecases.dart';
import 'categories_state.dart';

/// Mengelola daftar kategori (per tipe), tambah, dan hapus.
class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit({
    required WatchCategoriesUseCase watchCategories,
    required AddCategoryUseCase addCategory,
    required DeleteCategoryUseCase deleteCategory,
  })  : _watchCategories = watchCategories,
        _addCategory = addCategory,
        _deleteCategory = deleteCategory,
        super(const CategoriesState());

  final WatchCategoriesUseCase _watchCategories;
  final AddCategoryUseCase _addCategory;
  final DeleteCategoryUseCase _deleteCategory;

  StreamSubscription<Either<Failure, List<CategoryEntity>>>? _sub;

  /// Mulai (atau ganti) pengamatan daftar kategori untuk [type].
  void watch(CategoryType type) {
    _sub?.cancel();
    emit(state.copyWith(
      type: type,
      status: CategoriesStatus.loading,
      errorMessage: null,
    ));
    _sub = _watchCategories(type).listen((result) {
      result.fold(
        (f) => emit(state.copyWith(
          status: CategoriesStatus.failure,
          errorMessage: f.message,
        )),
        (list) => emit(state.copyWith(
          status: CategoriesStatus.success,
          categories: list,
          errorMessage: null,
        )),
      );
    });
  }

  Future<Either<Failure, CategoryEntity>> add({
    required String name,
    required CategoryType type,
    String? icon,
  }) =>
      _addCategory(AddCategoryParams(name: name, type: type, icon: icon));

  Future<Either<Failure, void>> delete(String id) => _deleteCategory(id);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
