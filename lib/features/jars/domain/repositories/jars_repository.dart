import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/jar_entity.dart';

abstract class JarsRepository {
  Stream<Either<Failure, List<JarEntity>>> watchJars();

  Future<Either<Failure, void>> addJar({
    required String title,
    required double target,
    DateTime? targetDate,
    String? icon,
  });

  Future<Either<Failure, void>> deleteJar(String id);

  /// Setor ke celengan; [walletId] (bila ada) dipotong saldonya.
  Future<Either<Failure, void>> deposit({
    required String jarId,
    required double amount,
    String? walletId,
    String? note,
  });
}
