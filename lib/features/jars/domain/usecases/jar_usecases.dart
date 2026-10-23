import 'package:Moneta/core/network/error/failures.dart';
import 'package:Moneta/core/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/jar_entity.dart';
import '../repositories/jars_repository.dart';

class WatchJarsUseCase {
  final JarsRepository repository;
  WatchJarsUseCase(this.repository);

  Stream<Either<Failure, List<JarEntity>>> call() => repository.watchJars();
}

class AddJarParams extends Equatable {
  final String title;
  final double target;
  final DateTime? targetDate;
  final String? icon;

  const AddJarParams({
    required this.title,
    required this.target,
    this.targetDate,
    this.icon,
  });

  @override
  List<Object?> get props => [title, target, targetDate, icon];
}

class AddJarUseCase implements UseCase<void, AddJarParams> {
  final JarsRepository repository;
  AddJarUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddJarParams p) => repository.addJar(
        title: p.title,
        target: p.target,
        targetDate: p.targetDate,
        icon: p.icon,
      );
}

class DepositJarParams extends Equatable {
  final String jarId;
  final double amount;
  final String? walletId;
  final String? note;

  const DepositJarParams({
    required this.jarId,
    required this.amount,
    this.walletId,
    this.note,
  });

  @override
  List<Object?> get props => [jarId, amount, walletId, note];
}

class DepositJarUseCase implements UseCase<void, DepositJarParams> {
  final JarsRepository repository;
  DepositJarUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DepositJarParams p) =>
      repository.deposit(
        jarId: p.jarId,
        amount: p.amount,
        walletId: p.walletId,
        note: p.note,
      );
}

class DeleteJarUseCase implements UseCase<void, String> {
  final JarsRepository repository;
  DeleteJarUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) => repository.deleteJar(id);
}
