import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/detected_transaction_entity.dart';

part 'detected_transaction_model.freezed.dart';

@freezed
abstract class DetectedTransactionModel with _$DetectedTransactionModel {
  const DetectedTransactionModel._();

  const factory DetectedTransactionModel({
    required String id,
    String? walletId,
    String? walletName,
    String? sourcePackage,
    required double amount,
    required String type,
    String? merchant,
    required DateTime detectedAt,
  }) = _DetectedTransactionModel;

  DetectedTransactionEntity toEntity() => DetectedTransactionEntity(
        id: id,
        walletId: walletId,
        walletName: walletName,
        sourcePackage: sourcePackage,
        amount: amount,
        type: DetectedType.fromValue(type),
        merchant: merchant,
        detectedAt: detectedAt,
      );
}
