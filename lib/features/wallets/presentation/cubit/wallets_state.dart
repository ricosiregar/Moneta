import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/wallet_entity.dart';

part 'wallets_state.freezed.dart';

enum WalletsStatus { initial, loading, success, failure }

@freezed
abstract class WalletsState with _$WalletsState {
  const factory WalletsState({
    @Default(WalletsStatus.initial) WalletsStatus status,
    @Default(<WalletEntity>[]) List<WalletEntity> wallets,
    String? errorMessage,
  }) = _WalletsState;
}
