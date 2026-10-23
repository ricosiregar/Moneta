import 'package:Moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/allocation_entity.dart';
import '../entities/ecosystem_child_entity.dart';
import '../entities/wallet_entity.dart';

/// Kontrak repository dompet, alokasi, dan transfer.
abstract class WalletsRepository {
  Stream<Either<Failure, List<WalletEntity>>> watchWallets();

  Future<Either<Failure, List<AllocationEntity>>> getAllocations(
    String sourceWalletId,
  );

  Future<Either<Failure, void>> saveWallet({
    String? id,
    required String name,
    required String type,
    String? parentId,
    String? purpose,
    bool isIncomeSource = false,
    double openingBalance = 0,
  });

  Future<Either<Failure, void>> saveWalletWithEcosystemChildren({
    String? id,
    required String name,
    required String type,
    String? parentId,
    String? purpose,
    bool isIncomeSource = false,
    double openingBalance = 0,
    required List<EcosystemChildEntity> ecosystemChildren,
  });

  Future<Either<Failure, void>> deleteWallet(String id);

  Future<Either<Failure, void>> saveAllocations(
    String sourceWalletId,
    Map<String, double> percents,
  );

  Future<Either<Failure, void>> distributeAllocations({
    required String sourceWalletId,
    required Map<String, double> percents,
    required double baseAmount,
  });

  Future<Either<Failure, void>> createTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    double fee = 0,
    String? note,
  });
}
