import 'package:flutter_test/flutter_test.dart';
import 'package:Moneta/core/database/app_database.dart';
import 'package:Moneta/core/database/finance_repository.dart';
import 'package:Moneta/core/database/wallet_repository.dart';
import 'package:Moneta/features/analytic/data/datasources/analytics_local_datasource.dart';
import 'package:Moneta/features/analytic/data/repositories/analytics_repository_impl.dart';
import 'package:Moneta/features/analytic/domain/usecases/analytics_usecases.dart';
import 'package:Moneta/features/analytic/presentation/cubit/analytics_cubit.dart';
import 'package:Moneta/features/wallets/data/datasources/wallets_local_datasource.dart';
import 'package:Moneta/features/wallets/data/repositories/wallets_repository_impl.dart';
import 'package:Moneta/features/wallets/domain/usecases/wallet_usecases.dart';

import 'support/test_helpers.dart';

void main() {
  late AppDatabase db;
  late FinanceRepository fin;

  Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 80));

  setUp(() async {
    db = newTestDb();
    fin = FinanceRepository(db);
    await addWallet(WalletRepository(db), 'W', opening: 1000);
    await addWallet(WalletRepository(db), 'V', opening: 1000);
  });
  tearDown(() => db.close());

  AnalyticsCubit cubit() {
    final repo = AnalyticsRepositoryImpl(
      localDataSource: AnalyticsLocalDataSourceImpl(finance: fin),
    );
    return AnalyticsCubit(
      watchWallets: WatchWalletsUseCase(WalletsRepositoryImpl(
        localDataSource:
            WalletsLocalDataSourceImpl(wallets: WalletRepository(db)),
      )),
      watchSummary: WatchSummaryUseCase(repo),
      watchExpenseByCategory: WatchExpenseByCategoryUseCase(repo),
      watchDaily: WatchDailyUseCase(repo),
      getCategoryTransactions: GetCategoryTransactionsUseCase(repo),
    );
  }

  test('ringkasan, kategori, harian, filter dompet, dan detail kategori',
      () async {
    final cat = await fin.addCategory(name: 'Makan', type: 'expense');
    await fin.addTransaction(
        walletId: 'W', categoryId: cat.id, type: 'expense', amount: 30);
    await fin.addTransaction(
        walletId: 'V', categoryId: cat.id, type: 'expense', amount: 20);
    await fin.addTransaction(walletId: 'W', type: 'income', amount: 100);

    final now = DateTime.now();
    final from = DateTime(now.year, now.month);
    final to = DateTime(now.year, now.month + 1);
    final c = cubit();
    addTearDown(c.close);

    c.load(from: from, to: to, trendFrom: DateTime(now.year, now.month - 5));
    await tick();
    expect(c.state.wallets.length, 2);
    expect(c.state.summary.expense, 50);
    expect(c.state.summary.income, 100);
    expect(c.state.categories.single.total, 50);
    expect(c.state.daily.single.expense, 50);
    expect(c.state.trend.isNotEmpty, isTrue);

    c.load(
        from: from,
        to: to,
        trendFrom: DateTime(now.year, now.month - 5),
        walletId: 'W');
    await tick();
    expect(c.state.summary.expense, 30);

    final r = await c.categoryTransactions(CategoryTransactionsParams(
        from: from, to: to, categoryId: cat.id, walletId: 'W'));
    expect(r.getOrElse(() => const []).single.amount, 30);
  });
}
