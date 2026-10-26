import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/core/utils/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/allocation_entity.dart';
import '../entities/ecosystem_child_entity.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallets_repository.dart';

class WatchWalletsUseCase {
  final WalletsRepository repository;
  WatchWalletsUseCase(this.repository);

  Stream<Either<Failure, List<WalletEntity>>> call() =>
      repository.watchWallets();
}

/// Ambil daftar dompet sekali (emisi pertama stream).
class GetWalletsUseCase implements UseCase<List<WalletEntity>, NoParams> {
  final WalletsRepository repository;
  GetWalletsUseCase(this.repository);

  @override
  Future<Either<Failure, List<WalletEntity>>> call(NoParams params) async {
    try {
      return await repository.watchWallets().first;
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}

class GetAllocationsUseCase
    implements UseCase<List<AllocationEntity>, String> {
  final WalletsRepository repository;
  GetAllocationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AllocationEntity>>> call(String sourceId) =>
      repository.getAllocations(sourceId);
}

class SaveWalletParams extends Equatable {
  final String? id;
  final String name;
  final String type;
  final String? parentId;
  final String? purpose;
  final bool isIncomeSource;
  final double openingBalance;

  /// Bila tidak kosong, dompet anak ekosistem dibuat sekaligus.
  final List<EcosystemChildEntity> ecosystemChildren;

  const SaveWalletParams({
    this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.purpose,
    this.isIncomeSource = false,
    this.openingBalance = 0,
    this.ecosystemChildren = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        parentId,
        purpose,
        isIncomeSource,
        openingBalance,
        ecosystemChildren,
      ];
}

class SaveWalletUseCase implements UseCase<void, SaveWalletParams> {
  final WalletsRepository repository;
  SaveWalletUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveWalletParams p) async {
    if (p.name.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Nama dompet wajib diisi'));
    }
    if (p.openingBalance.isNaN || p.openingBalance.isInfinite) {
      return const Left(ValidationFailure(message: 'Saldo awal tidak valid'));
    }
    if (p.ecosystemChildren.isNotEmpty) {
      return repository.saveWalletWithEcosystemChildren(
        id: p.id,
        name: p.name,
        type: p.type,
        parentId: p.parentId,
        purpose: p.purpose,
        isIncomeSource: p.isIncomeSource,
        openingBalance: p.openingBalance,
        ecosystemChildren: p.ecosystemChildren,
      );
    }
    return repository.saveWallet(
      id: p.id,
      name: p.name,
      type: p.type,
      parentId: p.parentId,
      purpose: p.purpose,
      isIncomeSource: p.isIncomeSource,
      openingBalance: p.openingBalance,
    );
  }
}

class DeleteWalletUseCase implements UseCase<void, String> {
  final WalletsRepository repository;
  DeleteWalletUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) => repository.deleteWallet(id);
}

class SaveAllocationsParams extends Equatable {
  final String sourceWalletId;
  final Map<String, double> percents;

  /// Bila diisi (> 0), saldo langsung didistribusikan sebesar nilai ini.
  final double? distributeAmount;

  const SaveAllocationsParams({
    required this.sourceWalletId,
    required this.percents,
    this.distributeAmount,
  });

  @override
  List<Object?> get props => [sourceWalletId, percents, distributeAmount];
}

class SaveAllocationsUseCase implements UseCase<void, SaveAllocationsParams> {
  final WalletsRepository repository;
  SaveAllocationsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveAllocationsParams p) {
    final amount = p.distributeAmount;
    if (amount != null && amount > 0) {
      return repository.distributeAllocations(
        sourceWalletId: p.sourceWalletId,
        percents: p.percents,
        baseAmount: amount,
      );
    }
    return repository.saveAllocations(p.sourceWalletId, p.percents);
  }
}

class CreateTransferParams extends Equatable {
  final String fromWalletId;
  final String toWalletId;
  final double amount;
  final double fee;
  final String? note;

  const CreateTransferParams({
    required this.fromWalletId,
    required this.toWalletId,
    required this.amount,
    this.fee = 0,
    this.note,
  });

  @override
  List<Object?> get props => [fromWalletId, toWalletId, amount, fee, note];
}

class CreateTransferUseCase implements UseCase<void, CreateTransferParams> {
  final WalletsRepository repository;
  CreateTransferUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateTransferParams p) =>
      repository.createTransfer(
        fromWalletId: p.fromWalletId,
        toWalletId: p.toWalletId,
        amount: p.amount,
        fee: p.fee,
        note: p.note,
      );
}
