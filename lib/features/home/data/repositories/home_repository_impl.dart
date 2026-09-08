import '../datasources/home_remote_datasource.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<WalletModel>> getWallets() => remoteDataSource.getWallets();

  @override
  Future<List<TransactionModel>> getTransactionsThisMonth() =>
      remoteDataSource.getTransactionsThisMonth();

  @override
  Future<List<TransactionModel>> getRecentTransactions({int limit = 10}) =>
      remoteDataSource.getRecentTransactions(limit: limit);

  @override
  Future<List<TransactionModel>> getTransactionsByPeriod(
    TransactionPeriod period,
  ) =>
      remoteDataSource.getTransactionsByPeriod(period);

  @override
  Future<double> getTotalExpenseThisMonth() =>
      remoteDataSource.getTotalExpenseThisMonth();

  @override
  Future<double> getTotalBalance() => remoteDataSource.getTotalBalance();

  @override
  Future<WalletModel> addWallet({
    required String name,
    required String type,
    required double balance,
    required String icon,
    required String color,
  }) =>
      remoteDataSource.addWallet(
        name: name,
        type: type,
        balance: balance,
        icon: icon,
        color: color,
      );
}
