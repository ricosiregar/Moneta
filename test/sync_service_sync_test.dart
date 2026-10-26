import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:moneta/core/database/app_database.dart';
import 'package:moneta/core/database/wallet_repository.dart';
import 'package:moneta/core/sync/sync_service.dart';

import 'support/test_helpers.dart';

String _b64(Map<String, dynamic> m) =>
    base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');

/// Sesi palsu (belum kedaluwarsa) supaya `auth.currentUser` terisi.
String _fakeSession() {
  final exp = DateTime.now().add(const Duration(hours: 1));
  final jwt = '${_b64({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${_b64({'sub': 'u1', 'exp': exp.millisecondsSinceEpoch ~/ 1000})}.sig';
  return jsonEncode({
    'access_token': jwt,
    'refresh_token': 'r',
    'token_type': 'bearer',
    'expires_in': 3600,
    'expires_at': exp.millisecondsSinceEpoch ~/ 1000,
    'user': {
      'id': 'u1',
      'aud': 'authenticated',
      'app_metadata': {},
      'user_metadata': {},
      'created_at': DateTime.now().toIso8601String(),
    },
  });
}

void main() {
  late AppDatabase db;
  late WalletRepository wallets;
  late SharedPreferences prefs;
  late SupabaseClient client;
  late SyncService sync;

  /// [pullRows]: isi respons GET per tabel. [failPost]: tabel yang POST-nya 400.
  Future<void> setup({
    Map<String, List<Map<String, dynamic>>> pullRows = const {},
    Set<String> failPost = const {},
    bool Function(Map<String, dynamic> row)? rejectRow,
  }) async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = newTestDb();
    wallets = WalletRepository(db);
    final mock = MockClient.streaming((req, bodyStream) async {
      final bodyText = await bodyStream.bytesToString();
      http.StreamedResponse resp(String b, int code) => http.StreamedResponse(
          Stream.value(utf8.encode(b)), code,
          request: req, headers: const {'content-type': 'application/json'});
            final table = req.url.pathSegments.last;
            if (req.method == 'GET') {
        // Halaman pertama berisi data, berikutnya kosong (hindari loop).
        final offset = req.url.queryParameters['offset'] ?? '0';
        final rows = offset == '0' ? (pullRows[table] ?? const []) : const [];
        return resp(jsonEncode(rows), 200);
      }
      final bad = failPost.contains(table);
      if (bad) {
        return resp(jsonEncode({'code': '23514', 'message': 'ditolak'}), 400);
      }
      if (rejectRow != null && req.method == 'POST') {
        final body = jsonDecode(bodyText);
        final list = body is List ? body : [body];
        if (list.any((r) => rejectRow(r as Map<String, dynamic>))) {
          return resp(jsonEncode({'code': '23514', 'message': 'row ditolak'}), 400);
        }
      }
      return resp('[]', 201);
    });
    client = SupabaseClient('http://localhost:54321', 'anon-key',
        httpClient: mock);
    await client.auth.recoverSession(_fakeSession());
    sync = SyncService(db: db, supabase: client, prefs: prefs);
  }

  tearDown(() async {
    await client.dispose();
    await db.close();
  });

  Future<List<String>> statuses(String id) async => (await db
          .customSelect('SELECT sync_status FROM wallets WHERE id = ?',
              variables: [Variable.withString(id)])
          .get())
      .map((r) => r.read<String>('sync_status'))
      .toList();

  test('push sukses: baris dirty menjadi synced', () async {
    await setup();
    await addWallet(wallets, 'A', opening: 5);
    expect(await statuses('A'), ['dirty']);

    final r = await sync.sync();

    expect(r.failed, 0);
    expect(r.pushed, greaterThanOrEqualTo(1));
    expect(await statuses('A'), ['synced']);
  });

  test('cursor = synced_at server terbesar (bukan jam perangkat)', () async {
    final t1 = DateTime.utc(2030, 1, 1, 10);
    final t2 = DateTime.utc(2030, 1, 1, 11);
    Map<String, dynamic> w(String id, DateTime t) => {
          'id': id,
          'name': id,
          'type': 'cash',
          'opening_balance': 0,
          'updated_at': t.toIso8601String(),
          'created_at': t.toIso8601String(),
          'synced_at': t.toIso8601String(),
        };
    await setup(pullRows: {
      'wallets': [w('R1', t1), w('R2', t2)],
    });

    await sync.sync();

    expect(DateTime.parse(prefs.getString('sync_server_cursor')!), t2);
  });

  test('push gagal total: baris kembali dirty (tidak tertinggal syncing)',
      () async {
    await setup(failPost: {'wallets'});
    await addWallet(wallets, 'A');

    await expectLater(sync.sync(), throwsA(isA<SyncException>()));

    expect(await statuses('A'), ['dirty']);
    // Cursor tidak maju bila sync gagal.
    expect(prefs.getString('sync_server_cursor'), isNull);
  });

  test('satu baris ditolak: yang lain tetap synced, failed dihitung',
      () async {
    await setup(rejectRow: (row) => row['id'] == 'BAD');
    await addWallet(wallets, 'GOOD');
    await addWallet(wallets, 'BAD');

    final r = await sync.sync();

    expect(r.failed, 1);
    expect(await statuses('GOOD'), ['synced']);
    expect(await statuses('BAD'), ['dirty']);
  });

  test('pull: baris rusak tidak menggagalkan baris lain', () async {
    final now = DateTime.now().toUtc().toIso8601String();
    await setup(pullRows: {
      'wallets': [
        {
          'id': 'R1',
          'name': 'Remote',
          'type': 'cash',
          'opening_balance': 7,
          'updated_at': now,
          'created_at': now,
        },
        // Rusak: id null melanggar NOT NULL.
        {'id': null, 'name': null, 'updated_at': now},
      ],
    });

    final r = await sync.sync();

    expect(r.pulled, greaterThanOrEqualTo(1));
    final rows = await db
        .customSelect("SELECT id FROM wallets WHERE id = 'R1'")
        .get();
    expect(rows.length, 1);
  });

  test('pull tidak menimpa baris lokal yang masih dirty', () async {
    final future = DateTime.now().toUtc().add(const Duration(hours: 1));
    await setup(failPost: {'wallets'}, pullRows: {
      'wallets': [
        {
          'id': 'A',
          'name': 'DARI-SERVER',
          'type': 'cash',
          'opening_balance': 0,
          'updated_at': future.toIso8601String(),
          'created_at': future.toIso8601String(),
        },
      ],
    });
    await addWallet(wallets, 'A');

    await expectLater(sync.sync(), throwsA(isA<SyncException>()));

    final r = await db
        .customSelect("SELECT name FROM wallets WHERE id = 'A'")
        .getSingle();
    expect(r.read<String>('name'), 'A');
  });

  test('baris syncing sisa crash dikembalikan ke dirty lalu terkirim',
      () async {
    await setup();
    await addWallet(wallets, 'A');
    await db.customStatement(
        "UPDATE wallets SET sync_status = 'syncing' WHERE id = 'A'");

    await sync.sync();

    expect(await statuses('A'), ['synced']);
  });
}
