import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/feed_item_entity.dart';

part 'feed_item_model.freezed.dart';

@freezed
abstract class FeedItemModel with _$FeedItemModel {
  const FeedItemModel._();

  const factory FeedItemModel({
    required String id,
    required String kind,
    required String title,
    required String category,
    String? iconKey,
    required String wallet,
    required double amount,
    required DateTime date,
    String? walletId,
    String? toWalletId,
    String? categoryId,
  }) = _FeedItemModel;

  FeedItemEntity toEntity() => FeedItemEntity(
        id: id,
        kind: FeedKind.fromValue(kind),
        title: title,
        category: category,
        iconKey: iconKey,
        wallet: wallet,
        amount: amount,
        date: date,
        walletId: walletId,
        toWalletId: toWalletId,
        categoryId: categoryId,
      );
}
