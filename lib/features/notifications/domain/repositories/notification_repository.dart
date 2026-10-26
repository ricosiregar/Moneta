import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/detected_transaction_entity.dart';
import '../entities/notification_source_entity.dart';

/// Kontrak repository deteksi transaksi dari notifikasi.
abstract class NotificationRepository {
  // ── Inbox ──
  Stream<Either<Failure, List<DetectedTransactionEntity>>> watchPending();

  /// true bila transaksi berhasil dibuat; false bila sudah diproses/tidak valid.
  Future<Either<Failure, bool>> record(String id);
  Future<Either<Failure, void>> ignore(String id);
  Future<Either<Failure, void>> ignoreAll();
  Future<Either<Failure, void>> changeWallet(String id, String walletId);
  Future<Either<Failure, void>> changeType(String id, String type);

  // ── Sumber notifikasi ──
  Stream<Either<Failure, List<NotificationSourceEntity>>> watchSources();
  Future<Either<Failure, void>> upsertSource({
    required String packageName,
    required String walletId,
  });
  Future<Either<Failure, void>> setSourceEnabled(String id, bool enabled);
  Future<Either<Failure, void>> deleteSource(String id);

  // ── Pengaturan ──
  Stream<Either<Failure, bool>> watchCaptureEnabled();
  Future<Either<Failure, void>> setCaptureEnabled(bool enabled);
}
