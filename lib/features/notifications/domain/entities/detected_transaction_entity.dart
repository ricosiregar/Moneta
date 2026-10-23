import 'package:freezed_annotation/freezed_annotation.dart';

part 'detected_transaction_entity.freezed.dart';

/// Jenis transaksi yang terdeteksi dari notifikasi.
enum DetectedType {
  income('income'),
  expense('expense');

  const DetectedType(this.value);
  final String value;

  static DetectedType fromValue(String value) =>
      value == 'income' ? DetectedType.income : DetectedType.expense;
}

/// Transaksi yang terdeteksi dari notifikasi bank dan menunggu dicatat.
@freezed
abstract class DetectedTransactionEntity with _$DetectedTransactionEntity {
  const factory DetectedTransactionEntity({
    required String id,
    String? walletId,
    String? walletName,
    String? sourcePackage,
    required double amount,
    required DetectedType type,
    String? merchant,
    required DateTime detectedAt,
  }) = _DetectedTransactionEntity;
}
