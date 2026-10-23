import 'package:Moneta/core/network/error/failures.dart';
import 'package:Moneta/core/utils/usecase.dart';
import 'package:dartz/dartz.dart';

import '../entities/cached_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetCachedProfileUseCase
    implements UseCase<CachedProfileEntity, NoParams> {
  final ProfileRepository repository;
  GetCachedProfileUseCase(this.repository);

  @override
  Future<Either<Failure, CachedProfileEntity>> call(NoParams params) =>
      repository.getCachedProfile();
}

class ExportJsonUseCase implements UseCase<void, NoParams> {
  final ProfileRepository repository;
  ExportJsonUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) =>
      repository.exportJson();
}

class ExportCsvUseCase implements UseCase<void, NoParams> {
  final ProfileRepository repository;
  ExportCsvUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) => repository.exportCsv();
}

class ImportJsonUseCase implements UseCase<int, String> {
  final ProfileRepository repository;
  ImportJsonUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(String source) =>
      repository.importJson(source);
}

class ClearAllDataUseCase implements UseCase<void, NoParams> {
  final ProfileRepository repository;
  ClearAllDataUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) => repository.clearAll();
}
