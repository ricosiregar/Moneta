import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../features/notifications/data/services/bank_parser.dart';
import 'app_database.dart';

class DetectedView {
  final String id;
  final String? walletId;
  final String? walletName;
  final String? sourcePackage;
  final double amount;
  final String type; // income | expense
  final String? merchant;
  final DateTime detectedAt;
  const DetectedView({
    required this.id,
    required this.walletId,
    required this.walletName,
    required this.sourcePackage,
    required this.amount,
    required this.type,
    required this.merchant,
    required this.detectedAt,
  });
}

class SourceView {
  final String id;
  final String packageName;
  final String walletId;
  final String parserKey;
  final bool isEnabled;
  const SourceView(
      this.id, this.packageName, this.walletId, this.parserKey, this.isEnabled);
}

/// Inbox transaksi terdeteksi + pemetaan aplikasi bank -> dompet.
class DetectedRepository {
  DetectedRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ── Inbox ──

  Stream<List<DetectedView>> watchPending() {
    return _db.customSelect(
      '''
      SELECT d.id, d.wallet_id, d.source_package, d.amount, d.type,
             d.merchant, d.detected_at, w.name AS wallet_name
      FROM detected_transactions d
      LEFT JOIN wallets w ON w.id = d.wallet_id AND w.deleted_at IS NULL
      WHERE d.status = 'pending' AND d.deleted_at IS NULL
      ORDER BY d.detected_at DESC
      ''',
      readsFrom: {_db.detectedTransactions, _db.wallets},
    ).watch().map((rows) => [
          for (final r in rows)
            DetectedView(
              id: r.read<String>('id'),
              walletId: r.readNullable<String>('wallet_id'),
              walletName: r.readNullable<String>('wallet_name'),
              sourcePackage: r.readNullable<String>('source_package'),
              amount: r.read<double>('amount'),
              type: r.read<String>('type'),
              merchant: r.readNullable<String>('merchant'),
              detectedAt: DateTime.fromMillisecondsSinceEpoch(
                  r.read<int>('detected_at') * 1000),
            ),
        ]);
  }

  /// Mencari dompet aktif yang cocok dengan `packageName` bank secara otomatis.
  /// Mengutamakan dompet Parent (`parentId == null`).
  Future<String?> resolveWalletIdForPackage(String packageName) async {
    final activeWallets = await (_db.select(_db.wallets)
          ..where((w) => w.deletedAt.isNull()))
        .get();
    if (activeWallets.isEmpty) return null;

    // 1. Cek jika ada pemetaan manual yang masih aktif dan dompetnya masih ada.
    final sources = await getEnabledSources();
    final mapped =
        sources.where((s) => s.packageName == packageName).firstOrNull;
    if (mapped != null &&
        activeWallets.any((w) => w.id == mapped.walletId)) {
      return mapped.walletId;
    }

    // 2. Auto-match berdasarkan nama bank dari packageName.
    final bankLabel = bankLabelForPackage(packageName);
    if (bankLabel == null) return null;

    final matchedParents = activeWallets
        .where((w) =>
            w.parentId == null && doesWalletMatchBank(w.name, bankLabel))
        .toList();
    if (matchedParents.isNotEmpty) return matchedParents.first.id;

    final matchedAny = activeWallets
        .where((w) => doesWalletMatchBank(w.name, bankLabel))
        .toList();
    if (matchedAny.isNotEmpty) return matchedAny.first.id;

    return null;
  }

  /// Jendela waktu untuk menganggap dua notifikasi identik sebagai duplikat.
  static const _dupWindowSeconds = 180;

  /// Simpan hasil deteksi. Notifikasi yang sama (fingerprint sama) diabaikan,
  /// begitu pula notifikasi identik (paket, nominal, tipe) dalam jendela
  /// ±[_dupWindowSeconds] detik, yang biasanya berasal dari event live yang
  /// terbaca ulang lewat scan tray atau notifikasi yang diposting ulang.
  Future<void> addDetected({
    required String fingerprint,
    required String? walletId,
    required String? sourcePackage,
    required double amount,
    required String type,
    String? merchant,
    required DateTime detectedAt,
  }) async {
    await _db.transaction(() async {
      final t = detectedAt.millisecondsSinceEpoch ~/ 1000;
      final dup = await _db.customSelect(
        'SELECT 1 FROM detected_transactions '
        'WHERE source_package IS ? AND amount = ? AND type = ? '
        'AND merchant IS ? '
        'AND deleted_at IS NULL AND detected_at BETWEEN ? AND ? LIMIT 1',
        variables: [
          Variable<String>(sourcePackage),
          Variable.withReal(amount),
          Variable.withString(type),
          Variable<String>(merchant),
          Variable.withInt(t - _dupWindowSeconds),
          Variable.withInt(t + _dupWindowSeconds),
        ],
      ).getSingleOrNull();
      if (dup != null) return;

      await _db.into(_db.detectedTransactions).insert(
            DetectedTransactionsCompanion.insert(
              id: _uuid.v4(),
              fingerprint: fingerprint,
              amount: amount,
              type: type,
              walletId: Value(walletId),
              sourcePackage: Value(sourcePackage),
              merchant: Value(merchant),
              detectedAt: Value(detectedAt),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    });
  }

  /// "Catat": jadikan transaksi sungguhan. Hanya entri `pending` yang diproses
  /// (cek dilakukan di dalam transaksi supaya tap ganda tidak menggandakan).
  /// Mengembalikan true bila transaksi berhasil dibuat.
  Future<bool> record(String id) async {
    return _db.transaction(() async {
      final row = await (_db.select(_db.detectedTransactions)
            ..where((d) => d.id.equals(id)))
          .getSingleOrNull();
      if (row == null ||
          row.walletId == null ||
          row.status != 'pending' ||
          row.deletedAt != null) {
        return false;
      }
      final now = DateTime.now();
      final txId = _uuid.v4();
      await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              id: txId,
              walletId: row.walletId!,
              title: row.merchant ?? 'Transaksi terdeteksi',
              amount: row.amount,
              type: row.type,
              date: Value(row.detectedAt),
              source: const Value('notification'),
              detectedId: Value(id),
            ),
          );
      await (_db.update(_db.detectedTransactions)..where((d) => d.id.equals(id)))
          .write(DetectedTransactionsCompanion(
        status: const Value('recorded'),
        transactionId: Value(txId),
        updatedAt: Value(now),
        syncStatus: const Value('dirty'),
      ));
      return true;
    });
  }

  Future<void> ignore(String id) => _setStatus(
      _db.detectedTransactions.id.equals(id), 'ignored');

  Future<void> ignoreAll() => _setStatus(
      _db.detectedTransactions.status.equals('pending'), 'ignored');

  Future<void> _setStatus(Expression<bool> where, String status) async {
    await (_db.update(_db.detectedTransactions)..where((_) => where)).write(
      DetectedTransactionsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('dirty'),
      ),
    );
  }

  /// "Pindah": ganti dompet tujuan pencatatan (tetap menunggu dicatat).
  Future<void> changeWallet(String id, String walletId) async {
    await (_db.update(_db.detectedTransactions)..where((d) => d.id.equals(id)))
        .write(DetectedTransactionsCompanion(
      walletId: Value(walletId),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('dirty'),
    ));
  }

  /// Ubah jenis (income/expense) transaksi terdeteksi bila hasil deteksi salah.
  Future<void> changeType(String id, String type) async {
    await (_db.update(_db.detectedTransactions)..where((d) => d.id.equals(id)))
        .write(DetectedTransactionsCompanion(
      type: Value(type),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('dirty'),
    ));
  }

  // ── Sumber notifikasi ──

  Stream<List<SourceView>> watchSources() {
    return (_db.select(_db.notificationSources)
          ..where((s) => s.deletedAt.isNull()))
        .watch()
        .map((rows) => [
              for (final s in rows)
                SourceView(s.id, s.packageName, s.walletId, s.parserKey,
                    s.isEnabled),
            ]);
  }

  Future<List<SourceView>> getEnabledSources() async {
    final rows = await (_db.select(_db.notificationSources)
          ..where((s) => s.deletedAt.isNull() & s.isEnabled.equals(true)))
        .get();
    return [
      for (final s in rows)
        SourceView(s.id, s.packageName, s.walletId, s.parserKey, s.isEnabled),
    ];
  }

  Future<void> upsertSource({
    required String packageName,
    required String walletId,
    String parserKey = 'generic',
    bool isEnabled = true,
  }) async {
    final matches = await (_db.select(_db.notificationSources)
          ..where(
              (s) => s.packageName.equals(packageName) & s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm(expression: s.createdAt)]))
        .get();
    final keepId = matches.isNotEmpty ? matches.first.id : _uuid.v4();
    await _db.transaction(() async {
      final now = DateTime.now();
      // Duplikat (mis. hasil sinkron dua perangkat) dibuang.
      for (final m in matches.skip(1)) {
        await (_db.update(_db.notificationSources)
              ..where((s) => s.id.equals(m.id)))
            .write(NotificationSourcesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value('dirty'),
        ));
      }
      await _db.into(_db.notificationSources).insertOnConflictUpdate(
            NotificationSourcesCompanion(
              id: Value(keepId),
              packageName: Value(packageName),
              walletId: Value(walletId),
              parserKey: Value(parserKey),
              isEnabled: Value(isEnabled),
              updatedAt: Value(now),
              syncStatus: const Value('dirty'),
            ),
          );
    });
  }

  Future<void> setSourceEnabled(String id, bool enabled) async {
    await (_db.update(_db.notificationSources)..where((s) => s.id.equals(id)))
        .write(NotificationSourcesCompanion(
      isEnabled: Value(enabled),
      updatedAt: Value(DateTime.now()),
      syncStatus: const Value('dirty'),
    ));
  }

  Future<void> deleteSource(String id) async {
    final now = DateTime.now();
    await (_db.update(_db.notificationSources)..where((s) => s.id.equals(id)))
        .write(NotificationSourcesCompanion(
      deletedAt: Value(now),
      updatedAt: Value(now),
      syncStatus: const Value('dirty'),
    ));
  }

  // ── Pengaturan deteksi ──

  Stream<bool> watchCaptureEnabled() {
    return _db.select(_db.userSettingsTable).watchSingleOrNull().map(
          (s) => s?.notificationCaptureEnabled ?? false,
        );
  }

  Future<bool> isCaptureEnabled() async {
    final s = await _db.select(_db.userSettingsTable).getSingleOrNull();
    return s?.notificationCaptureEnabled ?? false;
  }

  Future<void> setCaptureEnabled(bool enabled) async {
    await _db.into(_db.userSettingsTable).insertOnConflictUpdate(
          UserSettingsTableCompanion(
            id: const Value('me'),
            notificationCaptureEnabled: Value(enabled),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('dirty'),
          ),
        );
  }
}
