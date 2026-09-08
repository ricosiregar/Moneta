import '../models/transaction_model.dart';
import '../models/wallet_model.dart';

enum TransactionPeriod { daily, weekly, monthly }

abstract class HomeRepository {
  Future<List<WalletModel>> getWallets();
  Future<List<TransactionModel>> getTransactionsThisMonth();
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10});
  Future<List<TransactionModel>> getTransactionsByPeriod(TransactionPeriod period);
  Future<double> getTotalExpenseThisMonth();
  Future<double> getTotalBalance();
  Future<WalletModel> addWallet({
    required String name,
    required String type,
    required double balance,
    required String icon,
    required String color,
  });
}
