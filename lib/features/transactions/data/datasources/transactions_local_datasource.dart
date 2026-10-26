import 'package:moneta/core/database/finance_repository.dart';

import '../models/feed_item_model.dart';

/// Sumber data transaksi dari database lokal.
abstract class TransactionsLocalDataSource {
  Stream<List<FeedItemModel>> watchFeed();

  Future<void> addTransaction({
    required String walletId,
    String? categoryId,
    required String type,
    required double amount,
    String? note,
    DateTime? date,
  });

  Future<void> deleteTransaction(String id);
  Future<void> deleteTransfer(String id);
}

class TransactionsLocalDataSourceImpl implements TransactionsLocalDataSource {
  final FinanceRepository finance;

  TransactionsLocalDataSourceImpl({required this.finance});

  @override
  Stream<List<FeedItemModel>> watchFeed() => finance.watchFeed().map(
        (rows) => [
          for (final i in rows)
            FeedItemModel(
              id: i.id,
              kind: i.kind,
              title: i.title,
              category: i.category,
              iconKey: i.iconKey,
              wallet: i.wallet,
              amount: i.amount,
              date: i.date,
              walletId: i.walletId,
              toWalletId: i.toWalletId,
              categoryId: i.categoryId,
            ),
        ],
      );

  @override
  Future<void> addTransaction({
    required String walletId,
    String? categoryId,
    required String type,
    required double amount,
    String? note,
    DateTime? date,
  }) =>
      finance.addTransaction(
        walletId: walletId,
        categoryId: categoryId,
        type: type,
        amount: amount,
        note: note,
        date: date,
      );

  @override
  Future<void> deleteTransaction(String id) => finance.deleteTransaction(id);

  @override
  Future<void> deleteTransfer(String id) => finance.deleteTransfer(id);
}
