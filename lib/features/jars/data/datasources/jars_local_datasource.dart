import 'package:moneta/core/database/finance_repository.dart';

import '../models/jar_model.dart';

abstract class JarsLocalDataSource {
  Stream<List<JarModel>> watchJars();
  Future<void> addJar({
    required String title,
    required double target,
    DateTime? targetDate,
    String? icon,
  });
  Future<void> deleteJar(String id);
  Future<void> deposit({
    required String jarId,
    required double amount,
    String? walletId,
    String? note,
  });
}

class JarsLocalDataSourceImpl implements JarsLocalDataSource {
  final FinanceRepository finance;
  JarsLocalDataSourceImpl({required this.finance});

  @override
  Stream<List<JarModel>> watchJars() => finance.watchJars().map((rows) => [
        for (final j in rows)
          JarModel(
            id: j.id,
            title: j.title,
            target: j.target,
            saved: j.saved,
            icon: j.icon,
            targetDate: j.targetDate,
          ),
      ]);

  @override
  Future<void> addJar({
    required String title,
    required double target,
    DateTime? targetDate,
    String? icon,
  }) =>
      finance.addJar(
        title: title,
        target: target,
        targetDate: targetDate,
        icon: icon,
      );

  @override
  Future<void> deleteJar(String id) => finance.deleteJar(id);

  @override
  Future<void> deposit({
    required String jarId,
    required double amount,
    String? walletId,
    String? note,
  }) =>
      finance.deposit(
        jarId: jarId,
        amount: amount,
        walletId: walletId,
        note: note,
      );
}
