import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_item_entity.freezed.dart';

/// Jenis baris pada daftar aktivitas.
enum FeedKind {
  income('income'),
  expense('expense'),
  transfer('transfer');

  const FeedKind(this.value);
  final String value;

  static FeedKind fromValue(String value) => switch (value) {
        'income' => FeedKind.income,
        'transfer' => FeedKind.transfer,
        _ => FeedKind.expense,
      };
}

/// Satu baris aktivitas: pemasukan, pengeluaran, atau pindah uang.
@freezed
abstract class FeedItemEntity with _$FeedItemEntity {
  const FeedItemEntity._();

  const factory FeedItemEntity({
    required String id,
    required FeedKind kind,
    required String title,
    required String category,
    String? iconKey,
    required String wallet,
    required double amount,
    required DateTime date,
    String? walletId,
    String? toWalletId,
    String? categoryId,
  }) = _FeedItemEntity;

  bool get isTransfer => kind == FeedKind.transfer;
}
