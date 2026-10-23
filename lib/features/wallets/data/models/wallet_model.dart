import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/wallet_entity.dart';

part 'wallet_model.freezed.dart';

@freezed
abstract class WalletModel with _$WalletModel {
  const WalletModel._();

  const factory WalletModel({
    required String id,
    required String name,
    required String type,
    String? parentId,
    String? purpose,
    required bool isIncomeSource,
    required double openingBalance,
    required double balance,
  }) = _WalletModel;

  WalletEntity toEntity() => WalletEntity(
        id: id,
        name: name,
        type: type,
        parentId: parentId,
        purpose: purpose,
        isIncomeSource: isIncomeSource,
        openingBalance: openingBalance,
        balance: balance,
      );
}
