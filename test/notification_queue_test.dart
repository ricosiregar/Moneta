import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneta/core/database/app_database.dart';
import 'package:moneta/core/database/detected_repository.dart';
import 'package:moneta/core/database/wallet_repository.dart';
import 'package:moneta/features/notifications/data/services/bank_parser.dart';
import 'package:moneta/features/notifications/data/services/notification_capture_service.dart';

import 'support/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('moneta/notification_queue');

  late AppDatabase db;
  late DetectedRepository detected;
  late NotificationCaptureService service;
  late List<MethodCall> calls;
  late List<Map<String, Object?>> queue;

  setUp(() async {
    db = newTestDb();
    detected = DetectedRepository(db);
    service = NotificationCaptureService(detected, supportedOverride: true);
    await addWallet(WalletRepository(db), 'W', opening: 100);
    calls = [];
    queue = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'drain') {
        final out = [...queue];
        queue.clear();
        return out;
      }
      if (call.method == 'status') {
        return {'connected': true, 'ignoringBattery': false, 'queued': 2};
      }
      return null;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await db.close();
  });

  test('antrean native yang ditangkap saat app tertutup masuk ke inbox',
      () async {
    await detected.upsertSource(packageName: 'com.bank.x', walletId: 'W');
    await detected.setCaptureEnabled(true);
    queue = [
      {
        'id': 1,
        'packageName': 'com.bank.x',
        'title': 'Bank X',
        'content': 'Pembayaran di Kopi Kenangan sebesar Rp25.000 berhasil',
        'postTime': 1700000000000,
      },
      {
        // paket yang tidak dipantau -> diabaikan
        'id': 2,
        'packageName': 'com.lain',
        'title': 'x',
        'content': 'Pembayaran Rp1.000',
        'postTime': 1700000001000,
      },
      {
        // bukan transaksi -> diabaikan
        'id': 3,
        'packageName': 'com.bank.x',
        'title': 'Promo',
        'content': 'Dapatkan diskon spesial',
        'postTime': 1700000002000,
      },
    ];

    await service.drainQueue();
    final pending = await detected.watchPending().first;
    expect(pending.length, 1);
    expect(pending.single.amount, 25000);
    expect(pending.single.type, 'expense');
    expect(queue, isEmpty); // antrean dikosongkan

    // Membaca ulang notifikasi yang sama tidak menggandakan.
    queue = [
      {
        'id': 1,
        'packageName': 'com.bank.x',
        'title': 'Bank X',
        'content': 'Pembayaran di Kopi Kenangan sebesar Rp25.000 berhasil',
        'postTime': 1700000000000,
      },
    ];
    await service.drainQueue();
    expect((await detected.watchPending().first).length, 1);
  });

  test('daftar paket dikirim ke native; kosong saat fitur mati', () async {
    await detected.upsertSource(packageName: 'com.bank.x', walletId: 'W');

    await detected.setCaptureEnabled(true);
    await service.syncAllowedPackages();
    expect(calls.last.method, 'setAllowedPackages');
    final sent = (calls.last.arguments as List).cast<String>();
    // Bank bawaan (deteksi otomatis) selalu ikut, ditambah sumber kustom.
    expect(
      sent,
      containsAll([for (final k in knownBankPackages) k.$2]),
    );
    expect(sent, contains('com.bank.x'));
    expect(sent.toSet().length, sent.length, reason: 'tanpa duplikat');

    await detected.setCaptureEnabled(false);
    await service.syncAllowedPackages();
    expect(calls.last.arguments, isEmpty);
  });

  test('status listener dibaca dari native', () async {
    final st = await service.getStatus();
    expect(st.connected, isTrue);
    expect(st.ignoringBattery, isFalse);
    expect(st.queued, 2);
  });
}
