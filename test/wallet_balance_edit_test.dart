import 'package:flutter_test/flutter_test.dart';
import 'package:moneta/core/database/app_database.dart';
import 'package:moneta/core/database/wallet_repository.dart';

import 'support/test_helpers.dart';

void main() {
  late AppDatabase db;
  late WalletRepository repo;

  setUp(() {
    db = newTestDb();
    repo = WalletRepository(db);
  });
  tearDown(() => db.close());

  Future<List<Transaction>> txs() => db.select(db.transactions).get();

  Future<void> edit(String id, double balance) => repo.saveWallet(
        id: id,
        name: id,
        type: 'bank',
        openingBalance: balance,
      );

  test('dompet baru: saldo awal tersimpan, tanpa transaksi', () async {
    await addWallet(repo, 'A', opening: 5000);
    expect(await balanceOf(repo, 'A'), 5000);
    expect(await txs(), isEmpty);
  });

  test('edit saldo 0 -> 100k dicatat sebagai pemasukan', () async {
    await addWallet(repo, 'A');
    await edit('A', 100000);

    expect(await balanceOf(repo, 'A'), 100000);
    final t = await txs();
    expect(t, hasLength(1));
    expect(t.single.type, 'income');
    expect(t.single.amount, 100000);
    expect(t.single.walletId, 'A');
    expect(t.single.title, 'Penyesuaian saldo');
    expect(t.single.categoryId, isNull);
    expect(t.single.syncStatus, 'dirty');
  });

  test('edit saldo turun dicatat sebagai pengeluaran', () async {
    await addWallet(repo, 'A', opening: 100000);
    await edit('A', 60000);

    expect(await balanceOf(repo, 'A'), 60000);
    final t = await txs();
    expect(t.single.type, 'expense');
    expect(t.single.amount, 40000);
  });

  test('edit tanpa mengubah saldo tidak membuat transaksi', () async {
    await addWallet(repo, 'A', opening: 7000);
    await edit('A', 7000);
    expect(await txs(), isEmpty);
  });

  test('saldo awal asli dipertahankan; selisih dihitung dari saldo terkini',
      () async {
    await addWallet(repo, 'A', opening: 10000);
    await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            id: 't1',
            walletId: 'A',
            title: 'Gaji',
            amount: 50000,
            type: 'income',
          ),
        );
    expect(await balanceOf(repo, 'A'), 60000);

    await edit('A', 75000); // naik 15k dari saldo terkini
    expect(await balanceOf(repo, 'A'), 75000);
    final adj = (await txs()).where((t) => t.title == 'Penyesuaian saldo');
    expect(adj.single.amount, 15000);
    expect(adj.single.type, 'income');
  });

  test('mengubah hanya nama tidak mengubah saldo/transaksi', () async {
    await addWallet(repo, 'A', opening: 3000);
    await repo.saveWallet(
      id: 'A',
      name: 'Nama Baru',
      type: 'cash',
      openingBalance: 3000,
    );
    expect(await balanceOf(repo, 'A'), 3000);
    expect(await txs(), isEmpty);
  });
}
