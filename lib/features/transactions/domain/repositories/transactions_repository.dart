import 'package:Moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/feed_item_entity.dart';

/// Kontrak repository transaksi (daftar aktivitas, tambah, hapus).
abstract class TransactionsRepository {
  Stream<Either<Failure, List<FeedItemEntity>>> watchFeed();

  Future<Either<Failure, void>> addTransaction({
    required String walletId,
    String? categoryId,
    required FeedKind kind,
    required double amount,
    String? note,
    DateTime? date,
  });

  Future<Either<Failure, void>> deleteTransaction(String id);

  /// Hapus pindah uang (termasuk setoran/penarikan celengan).
  Future<Either<Failure, void>> deleteTransfer(String id);
}
