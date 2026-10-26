import 'package:moneta/core/network/error/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/cached_profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, CachedProfileEntity>> getCachedProfile();

  /// Bagikan cadangan JSON lewat share sheet.
  Future<Either<Failure, void>> exportJson();

  /// Bagikan transaksi sebagai CSV lewat share sheet.
  Future<Either<Failure, void>> exportCsv();

  /// Pulihkan dari isi berkas JSON; mengembalikan jumlah data dipulihkan.
  Future<Either<Failure, int>> importJson(String source);

  /// Hapus semua data lokal.
  Future<Either<Failure, void>> clearAll();
}
