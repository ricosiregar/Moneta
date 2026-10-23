import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:Moneta/core/database/app_database.dart';
import 'package:Moneta/core/database/finance_exception.dart';
import 'package:Moneta/core/database/finance_repository.dart';
import 'package:Moneta/core/database/wallet_repository.dart';

import 'support/test_helpers.dart';

void main() {
  late AppDatabase db;
  late FinanceRepository fin;
  late WalletRepository wal;

  setUp(() {
    db = newTestDb();
    fin = FinanceRepository(db);
    wal = WalletRepository(db);
  });

  tearDown(() async => db.close());

  group('seedDefaultCategories (#2)', () {
    test('seed dua kali pada DB yang sama tidak menggandakan', () async {
      await fin.seedDefaultCategories(userId: 'u1');
      await fin.seedDefaultCategories(userId: 'u1');
      expect(await totalCount(db, 'categories'), 12);
    });

    test('ID deterministik: dua "perangkat" user sama menghasilkan ID sama',
        () async {
      final db2 = newTestDb();
      addTearDown(db2.close);
      await fin.seedDefaultCategories(userId: 'u1');
      await FinanceRepository(db2).seedDefaultCategories(userId: 'u1');

      final a = (await db.select(db.categories).get()).map((c) => c.id).toSet();
      final b =
          (await db2.select(db2.categories).get()).map((c) => c.id).toSet();
      expect(a, b);
      expect(a.length, 12);
    });

    test('user berbeda menghasilkan ID berbeda', () async {
      final db2 = newTestDb();
      addTearDown(db2.close);
      await fin.seedDefaultCategories(userId: 'u1');
      await FinanceRepository(db2).seedDefaultCategories(userId: 'u2');

      final a = (await db.select(db.categories).get()).map((c) => c.id).toSet();
      final b =
          (await db2.select(db2.categories).get()).map((c) => c.id).toSet();
      expect(a.intersection(b), isEmpty);
    });

    test('tidak seed ulang bila kategori sengaja dihapus semua', () async {
      await fin.seedDefaultCategories(userId: 'u1');
      final ids = (await db.select(db.categories).get()).map((c) => c.id);
      for (final id in ids) {
        await fin.deleteCategory(id);
      }
      await fin.seedDefaultCategories(userId: 'u1');
      expect(await totalCount(db, 'categories'), 12);
      expect(await activeCount(db, 'categories'), 0);
    });

    test('tidak seed bila sudah ada kategori (mis. hasil pull dari cloud)',
        () async {
      await fin.addCategory(name: 'Kustom', type: 'expense');
      await fin.seedDefaultCategories(userId: 'u1');
      expect(await totalCount(db, 'categories'), 1);
    });
  });

  group('requireBalance', () {
    test('wallet tidak ada -> FinanceException', () async {
      expect(
        () => db.requireBalance('tidak-ada', 1),
        throwsA(isA<FinanceException>()),
      );
    });

    test('saldo pas diperbolehkan, kurang 1 rupiah ditolak', () async {
      await addWallet(wal, 'w', opening: 1000);
      await db.requireBalance('w', 1000);
      expect(
        () => db.requireBalance('w', 1001),
        throwsA(isA<FinanceException>()),
      );
    });

    test('wallet yang sudah dihapus dianggap tidak ada', () async {
      await addWallet(wal, 'w', opening: 1000);
      await wal.deleteWallet('w');
      expect(
        () => db.requireBalance('w', 1),
        throwsA(isA<FinanceException>()),
      );
    });
  });

  group('addTransaction validasi (#12)', () {
    test('nominal 0, negatif, NaN, tak hingga ditolak dan tidak menulis baris',
        () async {
      await addWallet(wal, 'w', opening: 1000);
      for (final bad in [0.0, -5.0, double.nan, double.infinity]) {
        await expectLater(
          fin.addTransaction(walletId: 'w', type: 'income', amount: bad),
          throwsA(isA<FinanceException>()),
          reason: 'amount=$bad',
        );
      }
      expect(await totalCount(db, 'transactions'), 0);
    });

    test('pengeluaran melebihi saldo ditolak, tidak ada baris tertulis',
        () async {
      await addWallet(wal, 'w', opening: 1000);
      await expectLater(
        fin.addTransaction(walletId: 'w', type: 'expense', amount: 1001),
        throwsA(isA<FinanceException>()),
      );
      expect(await totalCount(db, 'transactions'), 0);
      expect(await balanceOf(wal, 'w'), 1000);
    });

    test('pengeluaran tepat sama dengan saldo diterima -> saldo 0', () async {
      await addWallet(wal, 'w', opening: 1000);
      await fin.addTransaction(walletId: 'w', type: 'expense', amount: 1000);
      expect(await balanceOf(wal, 'w'), 0);
    });

    test('pemasukan ke wallet kosong diterima', () async {
      await addWallet(wal, 'w');
      await fin.addTransaction(walletId: 'w', type: 'income', amount: 500);
      expect(await balanceOf(wal, 'w'), 500);
    });
  });

  group('celengan (#6, #12)', () {
    Future<String> makeJar() async {
      await fin.addJar(title: 'Liburan', target: 50000);
      return (await db.select(db.savingJars).get()).single.id;
    }

    test('addJar menolak target <= 0', () async {
      await expectLater(
        fin.addJar(title: 'x', target: 0),
        throwsA(isA<FinanceException>()),
      );
    });

    test('deposit memotong saldo wallet dan menambah isi celengan', () async {
      await addWallet(wal, 'w', opening: 100000);
      final jar = await makeJar();
      await fin.deposit(jarId: jar, amount: 30000, walletId: 'w');
      expect(await balanceOf(wal, 'w'), 70000);
      expect((await fin.watchJars().first).single.saved, 30000);
    });

    test('deposit melebihi saldo ditolak dan tidak mengubah apa pun', () async {
      await addWallet(wal, 'w', opening: 1000);
      final jar = await makeJar();
      await expectLater(
        fin.deposit(jarId: jar, amount: 2000, walletId: 'w'),
        throwsA(isA<FinanceException>()),
      );
      expect(await totalCount(db, 'saving_jar_entries'), 0);
      expect((await fin.watchJars().first).single.saved, 0);
    });

    test('deposit ke celengan yang sudah dihapus -> FinanceException',
        () async {
      await addWallet(wal, 'w', opening: 1000);
      final jar = await makeJar();
      await fin.deleteJar(jar);
      await expectLater(
        fin.deposit(jarId: jar, amount: 10, walletId: 'w'),
        throwsA(isA<FinanceException>()),
      );
    });

    test('deleteJar mengembalikan setoran ke saldo wallet', () async {
      await addWallet(wal, 'w', opening: 100000);
      final jar = await makeJar();
      await fin.deposit(jarId: jar, amount: 30000, walletId: 'w');
      expect(await balanceOf(wal, 'w'), 70000);

      await fin.deleteJar(jar);

      expect(await balanceOf(wal, 'w'), 100000);
      expect(await activeCount(db, 'saving_jar_entries'), 0);
      expect(await activeCount(db, 'saving_jars'), 0);
    });

    test('deleteJar menandai entri dirty agar ikut tersinkron', () async {
      await addWallet(wal, 'w', opening: 100000);
      final jar = await makeJar();
      await fin.deposit(jarId: jar, amount: 10, walletId: 'w');
      await db.customStatement(
          "UPDATE saving_jar_entries SET sync_status = 'synced'");
      await fin.deleteJar(jar);
      final r = await db
          .customSelect('SELECT sync_status FROM saving_jar_entries')
          .getSingle();
      expect(r.read<String>('sync_status'), 'dirty');
    });
  });

  group('kategori & anggaran (#9, #17)', () {
    test('deleteCategory ikut menghapus anggaran kategori itu', () async {
      final c = await fin.addCategory(name: 'Makan', type: 'expense');
      await fin.saveBudget(categoryId: c.id, limit: 1000, month: 5, year: 2026);
      expect((await fin.watchBudgets(5, 2026).first).length, 1);

      await fin.deleteCategory(c.id);

      expect(await fin.watchBudgets(5, 2026).first, isEmpty);
    });

    test('transaksi kategori terhapus digabung ke satu baris "Lainnya"',
        () async {
      await addWallet(wal, 'w', opening: 100000);
      final c1 = await fin.addCategory(name: 'A', type: 'expense');
      final c2 = await fin.addCategory(name: 'B', type: 'expense');
      await fin.addTransaction(
          walletId: 'w', type: 'expense', amount: 100, categoryId: c1.id);
      await fin.addTransaction(
          walletId: 'w', type: 'expense', amount: 200, categoryId: c2.id);
      await fin.addTransaction(
          walletId: 'w', type: 'expense', amount: 300); // tanpa kategori
      await fin.deleteCategory(c1.id);
      await fin.deleteCategory(c2.id);

      final totals = await fin
          .watchExpenseByCategory(DateTime(2000), DateTime(2100))
          .first;
      expect(totals.length, 1);
      expect(totals.single.name, 'Lainnya');
      expect(totals.single.total, 600);
    });

    test('saveBudget tahan duplikat: pakai yang tertua, buang sisanya',
        () async {
      Future<void> raw(String id, DateTime created) =>
          db.into(db.budgetLimits).insert(BudgetLimitsCompanion.insert(
                id: id,
                monthlyLimit: 100,
                month: 5,
                year: 2026,
                createdAt: Value(created),
              ));
      await raw('b-baru', DateTime(2026, 3, 1));
      await raw('b-lama', DateTime(2026, 1, 1));

      final kept =
          await fin.saveBudget(limit: 555, month: 5, year: 2026); // semua kat.

      expect(kept, 'b-lama');
      final active = await fin.watchBudgets(5, 2026).first;
      expect(active.length, 1);
      expect(active.single.id, 'b-lama');
      expect(active.single.limit, 555);
    });

    test('saveBudget kedua untuk kategori+bulan yang sama meng-update', () async {
      final c = await fin.addCategory(name: 'A', type: 'expense');
      final a =
          await fin.saveBudget(categoryId: c.id, limit: 1, month: 1, year: 2026);
      final b =
          await fin.saveBudget(categoryId: c.id, limit: 2, month: 1, year: 2026);
      expect(a, b);
      expect(await activeCount(db, 'budget_limits'), 1);
    });
  });

  group('wallet terhapus tidak dihitung di laporan (#9)', () {
    test('ringkasan, feed, dan anggaran mengabaikan transaksi wallet terhapus',
        () async {
      await addWallet(wal, 'hidup', opening: 1000);
      await addWallet(wal, 'mati', opening: 1000);
      await fin.addTransaction(walletId: 'hidup', type: 'expense', amount: 100);
      await fin.addTransaction(walletId: 'mati', type: 'expense', amount: 400);

      var s = await fin.watchSummary(DateTime(2000), DateTime(2100)).first;
      expect(s.expense, 500);

      await wal.deleteWallet('mati');

      s = await fin.watchSummary(DateTime(2000), DateTime(2100)).first;
      expect(s.expense, 100);
      expect(s.count, 1);
      expect((await fin.watchFeed().first).length, 1);
    });
  });

  group('jadwal otomatis (#8)', () {
    final now = DateTime(2026, 3, 15, 10);

    Future<String> makeSchedule(double amount) => fin.saveAutoSchedule(
          title: 'Kos',
          kind: 'expense',
          amount: amount,
          dayOfMonth: 1,
          walletId: 'w',
        );

    test('tanpa force: hanya sekali per periode', () async {
      await addWallet(wal, 'w', opening: 100000);
      final id = await makeSchedule(30000);

      final first = await fin.executeAutoScheduleNow(id, now: now);
      final second = await fin.executeAutoScheduleNow(id, now: now);

      expect(first, isNotNull);
      expect(second, isNull);
      expect(await balanceOf(wal, 'w'), 70000);
      expect(await totalCount(db, 'transactions'), 1);
    });

    test('force: true tetap boleh mengulang (tombol manual)', () async {
      await addWallet(wal, 'w', opening: 100000);
      final id = await makeSchedule(30000);

      await fin.executeAutoScheduleNow(id, now: now);
      final again = await fin.executeAutoScheduleNow(id, now: now, force: true);

      expect(again, isNotNull);
      expect(await balanceOf(wal, 'w'), 40000);
    });

    test('dua eksekusi bersamaan -> hanya satu yang lolos', () async {
      await addWallet(wal, 'w', opening: 100000);
      final id = await makeSchedule(30000);

      final results = await Future.wait([
        fin.executeAutoScheduleNow(id, now: now),
        fin.executeAutoScheduleNow(id, now: now),
      ]);

      expect(results.where((r) => r != null).length, 1);
      expect(await balanceOf(wal, 'w'), 70000);
    });

    test('saldo kurang -> null dan tidak menulis transaksi', () async {
      await addWallet(wal, 'w', opening: 100);
      final id = await makeSchedule(500);

      final r = await fin.executeAutoScheduleNow(id, now: now);

      expect(r, isNull);
      expect(await totalCount(db, 'transactions'), 0);
    });

    test('bulan berbeda boleh dieksekusi lagi tanpa force', () async {
      await addWallet(wal, 'w', opening: 100000);
      final id = await makeSchedule(10000);

      await fin.executeAutoScheduleNow(id, now: DateTime(2026, 3, 15));
      final april =
          await fin.executeAutoScheduleNow(id, now: DateTime(2026, 4, 15));

      expect(april, isNotNull);
      expect(await balanceOf(wal, 'w'), 80000);
    });
  });
}
