import 'dart:async';

import 'package:Moneta/core/database/finance_exception.dart';
import 'package:Moneta/core/network/error/failures.dart';
import 'package:Moneta/core/utils/app_error_formatter.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/allocation_entity.dart';
import '../../domain/entities/ecosystem_child_entity.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallets_repository.dart';
import '../datasources/wallets_local_datasource.dart';
import '../models/wallet_model.dart';

class WalletsRepositoryImpl implements WalletsRepository {
  final WalletsLocalDataSource localDataSource;

  WalletsRepositoryImpl({required this.localDataSource});

  Failure _toFailure(Object e) {
    if (e is FinanceException) return ValidationFailure(message: e.message);
    return CacheFailure(message: AppErrorFormatter.format(e));
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } catch (e) {
      return Left(_toFailure(e));
    }
  }

  @override
  Stream<Either<Failure, List<WalletEntity>>> watchWallets() =>
      localDataSource.watchWallets().transform(
            StreamTransformer<List<WalletModel>,
                Either<Failure, List<WalletEntity>>>.fromHandlers(
              handleData: (rows, sink) => sink.add(
                Right([for (final r in rows) r.toEntity()]),
              ),
              handleError: (e, _, sink) => sink.add(Left(_toFailure(e))),
            ),
          );

  @override
  Future<Either<Failure, List<AllocationEntity>>> getAllocations(
    String sourceWalletId,
  ) =>
      _guard(() async => [
            for (final a in await localDataSource.getAllocations(sourceWalletId))
              a.toEntity(),
          ]);

  @override
  Future<Either<Failure, void>> saveWallet({
    String? id,
    required String name,
    required String type,
    String? parentId,
    String? purpose,
    bool isIncomeSource = false,
    double openingBalance = 0,
  }) =>
      _guard(() => localDataSource.saveWallet(
            id: id,
            name: name,
            type: type,
            parentId: parentId,
            purpose: purpose,
            isIncomeSource: isIncomeSource,
            openingBalance: openingBalance,
          ));

  @override
  Future<Either<Failure, void>> saveWalletWithEcosystemChildren({
    String? id,
    required String name,
    required String type,
    String? parentId,
    String? purpose,
    bool isIncomeSource = false,
    double openingBalance = 0,
    required List<EcosystemChildEntity> ecosystemChildren,
  }) =>
      _guard(() => localDataSource.saveWalletWithEcosystemChildren(
            id: id,
            name: name,
            type: type,
            parentId: parentId,
            purpose: purpose,
            isIncomeSource: isIncomeSource,
            openingBalance: openingBalance,
            ecosystemChildren: ecosystemChildren,
          ));

  @override
  Future<Either<Failure, void>> deleteWallet(String id) =>
      _guard(() => localDataSource.deleteWallet(id));

  @override
  Future<Either<Failure, void>> saveAllocations(
    String sourceWalletId,
    Map<String, double> percents,
  ) =>
      _guard(() => localDataSource.saveAllocations(sourceWalletId, percents));

  @override
  Future<Either<Failure, void>> distributeAllocations({
    required String sourceWalletId,
    required Map<String, double> percents,
    required double baseAmount,
  }) =>
      _guard(() => localDataSource.distributeAllocations(
            sourceWalletId: sourceWalletId,
            percents: percents,
            baseAmount: baseAmount,
          ));

  @override
  Future<Either<Failure, void>> createTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    double fee = 0,
    String? note,
  }) =>
      _guard(() => localDataSource.createTransfer(
            fromWalletId: fromWalletId,
            toWalletId: toWalletId,
            amount: amount,
            fee: fee,
            note: note,
          ));
}
