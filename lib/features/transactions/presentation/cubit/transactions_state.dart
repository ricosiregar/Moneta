import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../categories/domain/entities/category_entity.dart';
import '../../../wallets/domain/entities/wallet_entity.dart';
import '../../domain/entities/feed_item_entity.dart';

part 'transactions_state.freezed.dart';

enum TransactionsStatus { initial, loading, success, failure }

@freezed
abstract class TransactionsState with _$TransactionsState {
  const factory TransactionsState({
    @Default(TransactionsStatus.initial) TransactionsStatus status,
    @Default(<FeedItemEntity>[]) List<FeedItemEntity> items,
    @Default(<WalletEntity>[]) List<WalletEntity> wallets,
    @Default(<CategoryEntity>[]) List<CategoryEntity> categories,
    String? errorMessage,
  }) = _TransactionsState;
}
