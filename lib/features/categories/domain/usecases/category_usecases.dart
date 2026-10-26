import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';

class WatchCategoriesUseCase {
  final CategoryRepository repository;

  WatchCategoriesUseCase(this.repository);

  Stream<Either<Failure, List<CategoryEntity>>> call([CategoryType? type]) =>
      repository.watchCategories(type);
}

class AddCategoryParams extends Equatable {
  final String name;
  final CategoryType type;
  final String? icon;

  const AddCategoryParams({required this.name, required this.type, this.icon});

  @override
  List<Object?> get props => [name, type, icon];
}

class AddCategoryUseCase implements UseCase<CategoryEntity, AddCategoryParams> {
  final CategoryRepository repository;

  AddCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(AddCategoryParams params) async {
    final name = params.name.trim();
    if (name.isEmpty) {
      return const Left(ValidationFailure(message: 'Masukkan nama kategori'));
    }
    return repository.addCategory(
      name: name,
      type: params.type,
      icon: params.icon,
    );
  }
}

class DeleteCategoryUseCase implements UseCase<void, String> {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteCategory(id);
}
