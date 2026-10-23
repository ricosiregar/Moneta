import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter_test/flutter_test.dart';
import 'package:Moneta/core/database/app_database.dart';
import 'package:Moneta/core/database/detected_repository.dart';
import 'package:Moneta/core/database/finance_exception.dart';
import 'package:Moneta/core/database/wallet_repository.dart';

import 'support/test_helpers.dart';

void main() {
  late AppDatabase db;
  late WalletRepository repo;

  setUp(() {
    db = newTestDb();
    repo = WalletRepository(db);
  });
  tearDown(() => db.close());

  group('createTransfer (#11)', () {
    setUp(() async {
      await addWallet(repo, 'A', opening: 1000);
      await addWallet(repo, 'B');
    });

    Future<void> t({double amount = 100, double fee = 0, String to = 'B'}) =>
        repo.createTransfer(
            fromWalletId: 'A', toWalletId: to, amount: amount, fee: fee);

    test('nominal 0 ditolak', () {
      expect(t(amount: 0), throwsA(isA<FinanceException>()));
    });
    test('asal == tujuan ditolak', () {
      expect(t(to: 'A'), throwsA(isA<FinanceException>()));
    });
    test('biaya negatif ditolak', () {
      expect(t(fee: -1), throwsA(isA<FinanceException>()));
    });
    test('saldo kurang termasuk biaya ditolak, saldo tak berubah', () async {
      await expectLater(
          t(amount: 1000, fee: 1), throwsA(isA<FinanceException>()));
      expect(await balanceOf(repo, 'A'), 1000);
      expect(await balanceOf(repo, 'B'), 0);
    });
    test('amount + fee pas dengan saldo diterima', () async {
      await t(amount: 990, fee: 10);
      expect(await balanceOf(repo, 'A'), 0);
      expect(await balanceOf(repo, 'B'), 990);
    });
  });

  group('saveAllocations (#11)', () {
    setUp(() async {
      await addWallet(repo, 'S', opening: 100);
      await addWallet(repo, 'X');
      await addWallet(repo, 'Y');
      await addWallet(repo, 'Z');
    });

    test('total 100.5 ditolak', () {
      expect(repo.saveAllocations('S', {'X': 60, 'Y': 40.5}),
          throwsA(isA<FinanceException>()));
    });
    test('total tepat 100 diterima', () async {
      await repo.saveAllocations('S', {'X': 60, 'Y': 40});
      expect((await repo.getAllocations('S')).length, 2);
    });
    test('NaN ditolak', () {
      expect(repo.saveAllocations('S', {'X': double.nan}),
          throwsA(isA<FinanceException>()));
    });
    test('target = sumber ditolak', () {
      expect(repo.saveAllocations('S', {'S': 10}),
          throwsA(isA<FinanceException>()));
    });
    test('33.3 + 33.3 + 33.4 diterima (toleransi float)', () async {
      await repo.saveAllocations('S', {'X': 33.3, 'Y': 33.3, 'Z': 33.4});
      expect((await repo.getAllocations('S')).length, 3);
    });
  });

  group('distributeAllocations', () {
    test('pembulatan: total terdistribusi == persen total', () async {
      await addWallet(repo, 'S', opening: 100);
      for (final id in ['X', 'Y', 'Z']) {
        await addWallet(repo, id);
      }
      await repo.distributeAllocations(
        sourceWalletId: 'S',
        percents: {'X': 33.33, 'Y': 33.33, 'Z': 33.33},
        baseAmount: 100,
      );
      final sum = await balanceOf(repo, 'X') +
          await balanceOf(repo, 'Y') +
          await balanceOf(repo, 'Z');
      final left = await balanceOf(repo, 'S');
      // Tidak ada uang hilang / tercipta.
      expect(sum + left, closeTo(100, 0.001));
      // Bagian terakhir dikoreksi sehingga jumlah anak = 99.99 dibulatkan.
      expect(sum, closeTo(99.99, 1.0));
    });

    test('base > saldo: rollback total (tanpa transfer & alokasi)', () async {
      await addWallet(repo, 'S', opening: 50);
      await addWallet(repo, 'X');
      await expectLater(
        repo.distributeAllocations(
            sourceWalletId: 'S', percents: {'X': 100}, baseAmount: 100),
        throwsA(isA<FinanceException>()),
      );
      expect(await balanceOf(repo, 'S'), 50);
      expect(await balanceOf(repo, 'X'), 0);
      expect(await activeCount(db, 'wallet_allocations'), 0);
    });
  });

  group('deleteWallet cascade (#9)', () {
    test('menghapus semua dependensi', () async {
      await addWallet(repo, 'W', opening: 10);
      await addWallet(repo, 'C');
      await repo.saveAllocations('W', {'C': 50});
      await DetectedRepository(db)
          .upsertSource(packageName: 'com.bank', walletId: 'W');
      await db.into(db.userSettingsTable).insert(UserSettingsTableCompanion(
          id: const Value('me'), defaultExpenseWalletId: const Value('W')));
      await db.customStatement(
          "INSERT INTO auto_schedules (id, title, kind, amount, day_of_month, "
          "wallet_id) VALUES ('s1','x','expense',1,1,'W')");
      await repo.deleteWallet('W');
      expect(await activeCount(db, 'wallet_allocations'), 0);
      expect(await activeCount(db, 'notification_sources'), 0);
      final us = await db.select(db.userSettingsTable).getSingle();
      expect(us.defaultExpenseWalletId, isNull);
      final sch = await db
          .customSelect('SELECT deleted_at FROM auto_schedules WHERE id=?',
              variables: [Variable.withString('s1')])
          .getSingle();
      expect(sch.data['deleted_at'], isNotNull);
    });
  });
}
