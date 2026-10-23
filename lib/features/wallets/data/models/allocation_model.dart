import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/allocation_entity.dart';

part 'allocation_model.freezed.dart';

@freezed
abstract class AllocationModel with _$AllocationModel {
  const AllocationModel._();

  const factory AllocationModel({
    required String id,
    required String targetWalletId,
    double? percent,
    double? fixedAmount,
  }) = _AllocationModel;

  AllocationEntity toEntity() => AllocationEntity(
        id: id,
        targetWalletId: targetWalletId,
        percent: percent,
        fixedAmount: fixedAmount,
      );
}
