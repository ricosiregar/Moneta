import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/failure_guard.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/jar_entity.dart';
import '../../domain/repositories/jars_repository.dart';
import '../datasources/jars_local_datasource.dart';

class JarsRepositoryImpl implements JarsRepository {
  final JarsLocalDataSource localDataSource;
  JarsRepositoryImpl({required this.localDataSource});

  @override
  Stream<Either<Failure, List<JarEntity>>> watchJars() => guardStream(
        localDataSource.watchJars(),
        (rows) => [for (final r in rows) r.toEntity()],
      );

  @override
  Future<Either<Failure, void>> addJar({
    required String title,
    required double target,
    DateTime? targetDate,
    String? icon,
  }) =>
      guardLocal(() => localDataSource.addJar(
            title: title,
            target: target,
            targetDate: targetDate,
            icon: icon,
          ));

  @override
  Future<Either<Failure, void>> deleteJar(String id) =>
      guardLocal(() => localDataSource.deleteJar(id));

  @override
  Future<Either<Failure, void>> deposit({
    required String jarId,
    required double amount,
    String? walletId,
    String? note,
  }) =>
      guardLocal(() => localDataSource.deposit(
            jarId: jarId,
            amount: amount,
            walletId: walletId,
            note: note,
          ));
}
