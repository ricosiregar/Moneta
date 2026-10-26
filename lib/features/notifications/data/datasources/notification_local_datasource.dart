import 'package:moneta/core/database/detected_repository.dart';

import '../models/detected_transaction_model.dart';
import '../models/notification_source_model.dart';

/// Sumber data deteksi notifikasi dari database lokal.
abstract class NotificationLocalDataSource {
  Stream<List<DetectedTransactionModel>> watchPending();
  Future<bool> record(String id);
  Future<void> ignore(String id);
  Future<void> ignoreAll();
  Future<void> changeWallet(String id, String walletId);
  Future<void> changeType(String id, String type);

  Stream<List<NotificationSourceModel>> watchSources();
  Future<void> upsertSource({
    required String packageName,
    required String walletId,
  });
  Future<void> setSourceEnabled(String id, bool enabled);
  Future<void> deleteSource(String id);

  Stream<bool> watchCaptureEnabled();
  Future<void> setCaptureEnabled(bool enabled);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final DetectedRepository detected;

  NotificationLocalDataSourceImpl({required this.detected});

  @override
  Stream<List<DetectedTransactionModel>> watchPending() =>
      detected.watchPending().map((rows) => [
            for (final d in rows)
              DetectedTransactionModel(
                id: d.id,
                walletId: d.walletId,
                walletName: d.walletName,
                sourcePackage: d.sourcePackage,
                amount: d.amount,
                type: d.type,
                merchant: d.merchant,
                detectedAt: d.detectedAt,
              ),
          ]);

  @override
  Future<bool> record(String id) => detected.record(id);

  @override
  Future<void> ignore(String id) => detected.ignore(id);

  @override
  Future<void> ignoreAll() => detected.ignoreAll();

  @override
  Future<void> changeWallet(String id, String walletId) =>
      detected.changeWallet(id, walletId);

  @override
  Future<void> changeType(String id, String type) =>
      detected.changeType(id, type);

  @override
  Stream<List<NotificationSourceModel>> watchSources() =>
      detected.watchSources().map((rows) => [
            for (final s in rows)
              NotificationSourceModel(
                id: s.id,
                packageName: s.packageName,
                walletId: s.walletId,
                parserKey: s.parserKey,
                isEnabled: s.isEnabled,
              ),
          ]);

  @override
  Future<void> upsertSource({
    required String packageName,
    required String walletId,
  }) =>
      detected.upsertSource(packageName: packageName, walletId: walletId);

  @override
  Future<void> setSourceEnabled(String id, bool enabled) =>
      detected.setSourceEnabled(id, enabled);

  @override
  Future<void> deleteSource(String id) => detected.deleteSource(id);

  @override
  Stream<bool> watchCaptureEnabled() => detected.watchCaptureEnabled();

  @override
  Future<void> setCaptureEnabled(bool enabled) =>
      detected.setCaptureEnabled(enabled);
}
