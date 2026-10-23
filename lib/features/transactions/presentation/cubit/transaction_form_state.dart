import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../categories/domain/entities/category_entity.dart';
import '../../../wallets/domain/entities/wallet_entity.dart';

part 'transaction_form_state.freezed.dart';

@freezed
abstract class TransactionFormState with _$TransactionFormState {
  const factory TransactionFormState({
    @Default(<WalletEntity>[]) List<WalletEntity> wallets,
    @Default(<CategoryEntity>[]) List<CategoryEntity> categories,
  }) = _TransactionFormState;
}
