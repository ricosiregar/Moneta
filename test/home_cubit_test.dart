import 'package:flutter_test/flutter_test.dart';
import 'package:moneta/core/database/app_database.dart';
import 'package:moneta/core/database/finance_repository.dart';
import 'package:moneta/core/database/wallet_repository.dart';
import 'package:moneta/features/analytic/data/datasources/analytics_local_datasource.dart';
import 'package:moneta/features/analytic/data/repositories/analytics_repository_impl.dart';
import 'package:moneta/features/analytic/domain/usecases/analytics_usecases.dart';
import 'package:moneta/features/categories/data/datasources/category_local_datasource.dart';
import 'package:moneta/features/categories/data/repositories/category_repository_impl.dart';
import 'package:moneta/features/categories/domain/usecases/category_usecases.dart';
import 'package:moneta/features/home/presentation/cubit/home_cubit.dart';
import 'package:moneta/features/wallets/data/datasources/wallets_local_datasource.dart';
import 'package:moneta/features/wallets/data/repositories/wallets_repository_impl.dart';
import 'package:moneta/features/wallets/domain/usecases/wallet_usecases.dart';

import 'support/test_helpers.dart';

void main() {
  late AppDatabase db;
  late FinanceRepository fin;

  Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 80));

  setUp(() async {
    db = newTestDb();
    fin = FinanceRepository(db);
    await addWallet(WalletRepository(db), 'W', opening: 500);
    await addWallet(WalletRepository(db), 'V', opening: 500);
  });
  tearDown(() => db.close());

  test('home: dompet, kategori, ringkasan hari/minggu/bulan + filter dompet',
      () async {
    await fin.addCategory(name: 'Makan', type: 'expense');
    await fin.addCategory(name: 'Gaji', type: 'income');
    await fin.addTransaction(walletId: 'W', type: 'expense', amount: 30);
    await fin.addTransaction(walletId: 'V', type: 'expense', amount: 20);

    final c = HomeCubit(
      watchWallets: WatchWalletsUseCase(WalletsRepositoryImpl(
        localDataSource:
            WalletsLocalDataSourceImpl(wallets: WalletRepository(db)),
      )),
      watchCategories: WatchCategoriesUseCase(CategoryRepositoryImpl(
        localDataSource: CategoryLocalDataSourceImpl(finance: fin),
      )),
      watchSummary: WatchSummaryUseCase(AnalyticsRepositoryImpl(
        localDataSource: AnalyticsLocalDataSourceImpl(finance: fin),
      )),
    )..start();
    addTearDown(c.close);
    await tick();

    expect(c.state.wallets.length, 2);
    expect(c.state.expenseCategories.single.name, 'Makan');
    expect(c.state.summaries.map((s) => s.expense), [50, 50, 50]);

    c.watchSummaries(walletId: 'W');
    await tick();
    expect(c.state.summaries.map((s) => s.expense), [30, 30, 30]);
  });
}
