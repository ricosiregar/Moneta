import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:Moneta/core/database/app_database.dart';
import 'package:Moneta/core/database/wallet_repository.dart';
import 'package:Moneta/core/sync/sync_service.dart';

import 'support/test_helpers.dart';

void main() {
  late AppDatabase db;
  late WalletRepository wallets;
  late SupabaseClient client;
  late SharedPreferences prefs;
  late SyncService sync;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = newTestDb();
    wallets = WalletRepository(db);
    client = SupabaseClient('http://localhost:54321', 'anon-key');
    sync = SyncService(db: db, supabase: client, prefs: prefs);
    await addWallet(wallets, 'W', opening: 10);
  });
  tearDown(() async {
    await client.dispose();
    await db.close();
  });

  test('bind pertama: adopsi data lama, tidak menghapus', () async {
    expect(await sync.bindUser('u1'), isFalse);
    expect(prefs.getString('local_data_owner_id'), 'u1');
    expect(await activeCount(db, 'wallets'), 1);
  });

  test('user sama: data tetap', () async {
    await sync.bindUser('u1');
    expect(await sync.bindUser('u1'), isFalse);
    expect(await activeCount(db, 'wallets'), 1);
  });

  test('user berbeda: data & cursor dihapus, owner diganti', () async {
    await sync.bindUser('u1');
    await prefs.setString('sync_server_cursor', '2026-01-01T00:00:00Z');
    await db.customStatement(
        "INSERT INTO auto_schedules (id, title, kind, amount, day_of_month, "
        "wallet_id) VALUES ('s1','x','expense',1,1,'W')");

    expect(await sync.bindUser('u2'), isTrue);

    expect(await totalCount(db, 'wallets'), 0);
    expect(await totalCount(db, 'auto_schedules'), 0);
    expect(prefs.containsKey('sync_server_cursor'), isFalse);
    expect(prefs.getString('local_data_owner_id'), 'u2');
  });
}
