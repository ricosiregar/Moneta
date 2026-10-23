import 'package:freezed_annotation/freezed_annotation.dart';

part 'allocation_entity.freezed.dart';

/// Aturan alokasi dari wallet sumber ke wallet anak.
@freezed
abstract class AllocationEntity with _$AllocationEntity {
  const factory AllocationEntity({
    required String id,
    required String targetWalletId,
    double? percent,
    double? fixedAmount,
  }) = _AllocationEntity;
}
