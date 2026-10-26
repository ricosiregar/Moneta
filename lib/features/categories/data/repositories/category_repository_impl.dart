import 'dart:async';

import 'package:moneta/core/database/finance_exception.dart';
import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/app_error_formatter.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  Failure _toFailure(Object e) {
    if (e is FinanceException) return ValidationFailure(message: e.message);
    return CacheFailure(message: AppErrorFormatter.format(e));
  }

  @override
  Stream<Either<Failure, List<CategoryEntity>>> watchCategories(
    CategoryType? type,
  ) {
    return localDataSource.watchCategories(type?.value).transform(
          StreamTransformer<List<CategoryModel>,
              Either<Failure, List<CategoryEntity>>>.fromHandlers(
            handleData: (rows, sink) => sink.add(
              Right([for (final r in rows) r.toEntity()]),
            ),
            handleError: (e, _, sink) => sink.add(Left(_toFailure(e))),
          ),
        );
  }

  @override
  Future<Either<Failure, CategoryEntity>> addCategory({
    required String name,
    required CategoryType type,
    String? icon,
  }) async {
    try {
      final model = await localDataSource.addCategory(
        name: name,
        type: type.value,
        icon: icon,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await localDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(_toFailure(e));
    }
  }
}
