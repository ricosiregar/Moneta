import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/failure_guard.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/cached_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;
  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, CachedProfileEntity>> getCachedProfile() =>
      guardLocal(() async {
        final p = await localDataSource.getCachedProfile();
        return CachedProfileEntity(name: p.name, email: p.email);
      });

  @override
  Future<Either<Failure, void>> exportJson() =>
      guardLocal(localDataSource.exportJson);

  @override
  Future<Either<Failure, void>> exportCsv() =>
      guardLocal(localDataSource.exportCsv);

  /// Berkas cadangan rusak/tidak valid ([FormatException]) -> pesan jelas.
  @override
  Future<Either<Failure, int>> importJson(String source) async {
    try {
      return Right(await localDataSource.importJson(source));
    } on FormatException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(toLocalFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() =>
      guardLocal(localDataSource.clearAll);
}
