import 'package:moneta/core/database/wallet_repository.dart';

import '../../domain/entities/ecosystem_child_entity.dart';
import '../models/allocation_model.dart';
import '../models/wallet_model.dart';

/// Sumber data dompet dari database lokal.
abstract class WalletsLocalDataSource {
  Stream<List<WalletModel>> watchWallets();
  Future<List<AllocationModel>> getAllocations(String sourceWalletId);

  Future<void> saveWallet({
    String? id,
    required String name,
    required String type,
    String? parentId,
    String? purpose,
    bool isIncomeSource = false,
    double openingBalance = 0,
  });

  Future<void> saveWalletWithEcosystemChildren({
    String? id,
    required String name,
    required String type,
    String? parentId,
    String? purpose,
    bool isIncomeSource = false,
    double openingBalance = 0,
    required List<EcosystemChildEntity> ecosystemChildren,
  });

  Future<void> deleteWallet(String id);
  Future<void> saveAllocations(
      String sourceWalletId, Map<String, double> percents);
  Future<void> distributeAllocations({
    required String sourceWalletId,
    required Map<String, double> percents,
    required double baseAmount,
  });
  Future<void> createTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    double fee = 0,
    String? note,
  });
}

class WalletsLocalDataSourceImpl implements WalletsLocalDataSource {
  final WalletRepository wallets;

  WalletsLocalDataSourceImpl({required this.wallets});

  @override
  Stream<List<WalletModel>> watchWallets() => wallets.watchWallets().map(
        (rows) => [
          for (final w in rows)
            WalletModel(
              id: w.id,
              name: w.name,
              type: w.type,
              parentId: w.parentId,
              purpose: w.purpose,
              isIncomeSource: w.isIncomeSource,
              openingBalance: w.openingBalance,
              balance: w.balance,
            ),
        ],
      );

  @override
  Future<List<AllocationModel>> getAllocations(String sourceWalletId) async {
    final rows = await wallets.getAllocations(sourceWalletId);
    return [
      for (final a in rows)
        AllocationModel(
          id: a.id,
          targetWalletId: a.targetWalletId,
          percent: a.percent,
          fixedAmount: a.fixedAmount,
        ),
    ];
  }

  @override
  Future<void> saveWallet({
    String? id,
    required String name,
    required String type,
    String? parentId,
    String? purpose,
    bool isIncomeSource = false,
    double openingBalance = 0,
  }) =>
      wallets.saveWallet(
        id: id,
        name: name,
        type: type,
        parentId: parentId,
        purpose: purpose,
        isIncomeSource: isIncomeSource,
        openingBalance: openingBalance,
      );

  @override
  Future<void> saveWalletWithEcosystemChildren({
    String? id,
    required String name,
    required String type,
    String? parentId,
    String? purpose,
    bool isIncomeSource = false,
    double openingBalance = 0,
    required List<EcosystemChildEntity> ecosystemChildren,
  }) =>
      wallets.saveWalletWithEcosystemChildren(
        id: id,
        name: name,
        type: type,
        parentId: parentId,
        purpose: purpose,
        isIncomeSource: isIncomeSource,
        openingBalance: openingBalance,
        ecosystemChildren: [
          for (final c in ecosystemChildren)
            (
              name: c.name,
              type: c.type,
              purpose: c.purpose,
              openingBalance: c.openingBalance,
            ),
        ],
      );

  @override
  Future<void> deleteWallet(String id) => wallets.deleteWallet(id);

  @override
  Future<void> saveAllocations(
          String sourceWalletId, Map<String, double> percents) =>
      wallets.saveAllocations(sourceWalletId, percents);

  @override
  Future<void> distributeAllocations({
    required String sourceWalletId,
    required Map<String, double> percents,
    required double baseAmount,
  }) =>
      wallets.distributeAllocations(
        sourceWalletId: sourceWalletId,
        percents: percents,
        baseAmount: baseAmount,
      );

  @override
  Future<void> createTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    double fee = 0,
    String? note,
  }) =>
      wallets.createTransfer(
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        fee: fee,
        note: note,
      );
}
