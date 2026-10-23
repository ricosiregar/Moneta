import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_entity.freezed.dart';

/// Wallet beserta saldo hasil hitung ledger.
@freezed
abstract class WalletEntity with _$WalletEntity {
  const factory WalletEntity({
    required String id,
    required String name,

    /// cash | bank | e_wallet
    required String type,
    String? parentId,
    String? purpose,
    required bool isIncomeSource,
    required double openingBalance,
    required double balance,
  }) = _WalletEntity;
}
