import 'package:flutter_test/flutter_test.dart';
import 'package:moneta/core/database/app_database.dart';
import 'package:moneta/core/database/finance_repository.dart';
import 'package:moneta/core/database/wallet_repository.dart';
import 'package:moneta/core/network/error/failures.dart';
import 'package:moneta/features/categories/data/datasources/category_local_datasource.dart';
import 'package:moneta/features/categories/data/repositories/category_repository_impl.dart';
import 'package:moneta/features/categories/domain/usecases/category_usecases.dart';
import 'package:moneta/features/transactions/data/datasources/transactions_local_datasource.dart';
import 'package:moneta/features/transactions/data/repositories/transactions_repository_impl.dart';
import 'package:moneta/features/transactions/domain/entities/feed_item_entity.dart';
import 'package:moneta/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:moneta/features/transactions/presentation/cubit/transaction_form_cubit.dart';
import 'package:moneta/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:moneta/features/transactions/presentation/cubit/transactions_state.dart';
import 'package:moneta/features/wallets/data/datasources/wallets_local_datasource.dart';
import 'package:moneta/features/wallets/data/repositories/wallets_repository_impl.dart';
import 'package:moneta/features/wallets/domain/usecases/wallet_usecases.dart';

import 'support/test_helpers.dart';

void main() {
  late AppDatabase db;
  late FinanceRepository fin;
  late TransactionsRepositoryImpl txRepo;
  late WatchWalletsUseCase watchWallets;
  late WatchCategoriesUseCase watchCategories;

  Future<void> tick() => Future<void>.delayed(const Duration(milliseconds: 60));

  setUp(() async {
    db = newTestDb();
    fin = FinanceRepository(db);
    txRepo = TransactionsRepositoryImpl(
      localDataSource: TransactionsLocalDataSourceImpl(finance: fin),
    );
    watchWallets = WatchWalletsUseCase(WalletsRepositoryImpl(
      localDataSource:
          WalletsLocalDataSourceImpl(wallets: WalletRepository(db)),
    ));
    watchCategories = WatchCategoriesUseCase(CategoryRepositoryImpl(
      localDataSource: CategoryLocalDataSourceImpl(finance: fin),
    ));
    await addWallet(WalletRepository(db), 'W', opening: 100);
  });
  tearDown(() => db.close());

  TransactionFormCubit form() => TransactionFormCubit(
        watchWallets: watchWallets,
        watchCategories: watchCategories,
        addTransaction: AddTransactionUseCase(txRepo),
      )..start();

  TransactionsCubit list() => TransactionsCubit(
        watchFeed: WatchFeedUseCase(txRepo),
        watchWallets: watchWallets,
        watchCategories: watchCategories,
        deleteItem: DeleteFeedItemUseCase(txRepo),
      )..watch();

  test('form: validasi nominal & jenis, simpan, lalu tampil di feed', () async {
    final f = form();
    final l = list();
    addTearDown(() async {
      await f.close();
      await l.close();
    });
    await tick();
    expect(f.state.wallets.single.id, 'W');

    Future<Failure?> failOf(AddTransactionParams p) async =>
        (await f.save(p)).fold((e) => e, (_) => null);

    expect(
        await failOf(const AddTransactionParams(
            walletId: 'W', kind: FeedKind.expense, amount: 0)),
        isA<ValidationFailure>());
    expect(
        await failOf(const AddTransactionParams(
            walletId: 'W', kind: FeedKind.transfer, amount: 5)),
        isA<ValidationFailure>());
    expect(
        await failOf(const AddTransactionParams(
            walletId: '', kind: FeedKind.income, amount: 5)),
        isA<ValidationFailure>());
    // Melebihi saldo ditolak oleh database -> ValidationFailure.
    expect(
        await failOf(const AddTransactionParams(
            walletId: 'W', kind: FeedKind.expense, amount: 500)),
        isA<ValidationFailure>());

    expect(
        (await f.save(AddTransactionParams(
                walletId: 'W',
                kind: FeedKind.expense,
                amount: 40,
                note: 'makan',
                date: DateTime.now())))
            .isRight(),
        isTrue);
    await tick();
    expect(l.state.status, TransactionsStatus.success);
    expect(l.state.items.single.kind, FeedKind.expense);
    expect(l.state.items.single.amount, 40);
    expect(l.state.wallets.single.balance, 60);
  });

  test('hapus transaksi dan pindah uang lewat DeleteFeedItemUseCase', () async {
    final l = list();
    addTearDown(l.close);
    await addWallet(WalletRepository(db), 'B');
    await fin.addTransaction(walletId: 'W', type: 'income', amount: 10);
    await WalletRepository(db).createTransfer(
        fromWalletId: 'W', toWalletId: 'B', amount: 20);
    await tick();
    expect(l.state.items.length, 2);

    final tx = l.state.items.firstWhere((i) => !i.isTransfer);
    final tr = l.state.items.firstWhere((i) => i.isTransfer);
    expect((await l.delete(tx.id, isTransfer: false)).isRight(), isTrue);
    expect((await l.delete(tr.id, isTransfer: true)).isRight(), isTrue);
    await tick();
    expect(l.state.items, isEmpty);
    expect(l.state.wallets.firstWhere((w) => w.id == 'W').balance, 100);
  });

  test('kategori semua jenis tersedia untuk filter', () async {
    await fin.addCategory(name: 'Kopi', type: 'expense');
    await fin.addCategory(name: 'Bonus', type: 'income');
    final l = list();
    addTearDown(l.close);
    await tick();
    expect(l.state.categories.map((c) => c.name), containsAll(['Kopi', 'Bonus']));
  });
}
