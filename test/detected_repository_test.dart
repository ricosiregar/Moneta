import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:Moneta/core/database/app_database.dart';
import 'package:Moneta/core/database/detected_repository.dart';
import 'package:Moneta/core/database/wallet_repository.dart';

import 'support/test_helpers.dart';

void main() {
  late AppDatabase db;
  late WalletRepository wallets;
  late DetectedRepository repo;
  final base = DateTime(2026, 1, 1, 10);

  setUp(() async {
    db = newTestDb();
    wallets = WalletRepository(db);
    repo = DetectedRepository(db);
    await addWallet(wallets, 'W', opening: 1000);
  });
  tearDown(() => db.close());

  Future<void> add(String fp,
          {double amount = 50,
          String type = 'expense',
          int plusSec = 0,
          String? wallet = 'W'}) =>
      repo.addDetected(
        fingerprint: fp,
        walletId: wallet,
        sourcePackage: 'com.bank',
        amount: amount,
        type: type,
        detectedAt: base.add(Duration(seconds: plusSec)),
      );

  group('addDetected dedupe (#13)', () {
    test('identik dalam +60 dtk diabaikan', () async {
      await add('a');
      await add('b', plusSec: 60);
      expect(await activeCount(db, 'detected_transactions'), 1);
    });
    test('identik +400 dtk (di luar jendela) disimpan', () async {
      await add('a');
      await add('b', plusSec: 400);
      expect(await activeCount(db, 'detected_transactions'), 2);
    });
    test('nominal / tipe berbeda disimpan', () async {
      await add('a');
      await add('b', amount: 51);
      await add('c', type: 'income');
      expect(await activeCount(db, 'detected_transactions'), 3);
    });
    test('fingerprint sama diabaikan walau di luar jendela', () async {
      await add('a');
      await add('a', plusSec: 1000);
      expect(await activeCount(db, 'detected_transactions'), 1);
    });
  });

  group('record (#7)', () {
    Future<String> firstId() async =>
        (await db.select(db.detectedTransactions).get()).first.id;

    test('true sekali lalu false; hanya satu transaksi', () async {
      await add('a');
      final id = await firstId();
      expect(await repo.record(id), isTrue);
      expect(await repo.record(id), isFalse);
      expect(await activeCount(db, 'transactions'), 1);
      expect(await balanceOf(wallets, 'W'), 950);
    });
    test('wallet null -> false', () async {
      await add('a', wallet: null);
      expect(await repo.record(await firstId()), isFalse);
      expect(await activeCount(db, 'transactions'), 0);
    });
    test('id tidak ada -> false', () async {
      expect(await repo.record('nope'), isFalse);
    });
    test('dua record bersamaan -> hanya satu transaksi', () async {
      await add('a');
      final id = await firstId();
      final r = await Future.wait([repo.record(id), repo.record(id)]);
      expect(r.where((x) => x).length, 1);
      expect(await activeCount(db, 'transactions'), 1);
    });
  });

  group('upsertSource (#19)', () {
    test('duplikat dibuang, yang tertua dipertahankan', () async {
      final t0 = DateTime(2026, 1, 1);
      await db.into(db.notificationSources).insert(
          NotificationSourcesCompanion.insert(
              id: 'old',
              packageName: 'com.bank',
              parserKey: 'generic',
              walletId: 'W',
              createdAt: Value(t0)));
      await db.into(db.notificationSources).insert(
          NotificationSourcesCompanion.insert(
              id: 'new',
              packageName: 'com.bank',
              parserKey: 'generic',
              walletId: 'W',
              createdAt: Value(t0.add(const Duration(days: 1)))));
      await repo.upsertSource(packageName: 'com.bank', walletId: 'W');
      final rows = await (db.select(db.notificationSources)
            ..where((s) => s.deletedAt.isNull()))
          .get();
      expect(rows.map((e) => e.id), ['old']);
    });
  });
}
