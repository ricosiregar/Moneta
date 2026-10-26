import 'package:drift/drift.dart' show Variable;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';

/// Hasil satu kali sinkronisasi.
class SyncResult {
  final int pulled;
  final int pushed;

  /// Jumlah baris yang gagal diproses (dilewati, akan dicoba lagi di sync
  /// berikutnya) tanpa menggagalkan seluruh sinkronisasi.
  final int failed;
  const SyncResult({
    required this.pulled,
    required this.pushed,
    this.failed = 0,
  });
}

class SyncException implements Exception {
  final String message;
  const SyncException(this.message);

  @override
  String toString() => message;
}

class _TableSpec {
  final String name;
  final Set<String> dateCols;
  final Set<String> boolCols;

  /// Kunci unik lokal ('id'). Untuk user_settings kunci remote = user_id.
  final bool isUserSettings;

  const _TableSpec(
    this.name, {
    this.dateCols = const {'created_at', 'updated_at', 'deleted_at'},
    this.boolCols = const {},
    this.isUserSettings = false,
  });
}

/// Sinkronisasi manual local-first: Drift (lokal) <-> Supabase.
///
/// Urutan: **pull** dulu, lalu **push**.
/// - Pull: ambil baris remote dengan `updated_at > cursor`. Baris lokal yang
///   masih `dirty` tidak pernah ditimpa (perubahan lokal yang belum terkirim
///   selalu menang dan akan dikirim pada tahap push).
/// - Push: kirim semua baris `dirty` (upsert), lalu tandai `synced`.
class SyncService {
  SyncService({
    required AppDatabase db,
    required SupabaseClient supabase,
    required SharedPreferences prefs,
  })  : _db = db,
        _supabase = supabase,
        _prefs = prefs;

  final AppDatabase _db;
  final SupabaseClient _supabase;
  final SharedPreferences _prefs;

  // Kunci baru: nilainya kini waktu SERVER (synced_at), bukan jam perangkat,
  // sehingga cursor lama (jam klien) sengaja tidak dipakai.
  static const _cursorKey = 'sync_server_cursor';
  static const _ownerKey = 'local_data_owner_id';
  static const _pageSize = 500;
  static const _batchSize = 200;

  bool _running = false;
  bool get isRunning => _running;

  /// Urut sesuai dependensi foreign key.
  static const _tables = <_TableSpec>[
    _TableSpec('categories'),
    _TableSpec('wallets',
        boolCols: {'is_income_source', 'is_archived'}),
    _TableSpec('detected_transactions',
        dateCols: {'created_at', 'updated_at', 'deleted_at', 'detected_at'}),
    _TableSpec('transactions',
        dateCols: {'created_at', 'updated_at', 'deleted_at', 'date'}),
    _TableSpec('wallet_allocations'),
    _TableSpec('transfers',
        dateCols: {'created_at', 'updated_at', 'deleted_at', 'date'}),
    _TableSpec('notification_sources', boolCols: {'is_enabled'}),
    _TableSpec('budget_limits'),
    _TableSpec('auto_schedules',
        dateCols: {
          'created_at',
          'updated_at',
          'deleted_at',
          'last_executed_at',
        },
        boolCols: {'is_enabled'}),
    _TableSpec('saving_jars',
        dateCols: {'created_at', 'updated_at', 'deleted_at', 'target_date'},
        boolCols: {'is_completed'}),
    _TableSpec('saving_jar_entries',
        dateCols: {'created_at', 'updated_at', 'deleted_at', 'date'}),
    _TableSpec('user_settings',
        dateCols: {'updated_at', 'last_synced_at'},
        boolCols: {'notification_capture_enabled'},
        isUserSettings: true),
  ];

  final Map<String, List<String>> _columnCache = {};

  /// Pastikan data lokal milik [userId]. Bila sebelumnya dimiliki akun lain,
  /// data lokal + cursor sync dihapus agar tidak tampil ke / ter-upload ke
  /// akun baru. Mengembalikan true bila data dihapus.
  ///
  /// Pemilik yang belum tercatat (instalasi lama) dianggap milik [userId].
  Future<bool> bindUser(String userId) async {
    if (_running) return false;
    final owner = _prefs.getString(_ownerKey);
    if (owner == userId) return false;
    var wiped = false;
    if (owner != null) {
      await _db.wipeAllData();
      await _prefs.remove(_cursorKey);
      wiped = true;
    }
    await _prefs.setString(_ownerKey, userId);
    return wiped;
  }

  /// Kembalikan baris yang tertinggal berstatus 'syncing' (mis. app tertutup
  /// saat sync) ke 'dirty' agar dikirim ulang.
  Future<void> _resetSyncing() async {
    for (final spec in _tables) {
      try {
        await _db.customStatement(
          "UPDATE ${spec.name} SET sync_status = 'dirty' "
          "WHERE sync_status = 'syncing'",
        );
      } catch (_) {
        // Tabel opsional (mis. auto_schedules) bisa belum ada.
      }
    }
  }

  Future<SyncResult> sync() async {
    if (_running) throw const SyncException('Sinkronisasi sedang berjalan');
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const SyncException('Masuk dulu untuk sinkronisasi');
    }

    _running = true;
    // FK dimatikan sementara karena data remote bisa datang tidak berurutan
    // (mis. wallet anak sebelum induk). Integritas dijaga oleh Supabase.
    await _db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      await _resetSyncing();
      _failed = 0;
      _pushedDetectedIds.clear();
      _maxSeenSyncedAt = null;
      final cursor = await _pullCursor();

      var pulled = 0;
      for (final spec in _tables) {
        try {
          pulled += await _pull(spec, cursor);
        } on PostgrestException {
          if (spec.name != 'auto_schedules') rethrow;
        }
      }

      // customStatement tidak memicu stream Drift; beri tahu manual agar UI
      // yang memakai .watch() ikut refresh dengan data hasil pull.
      if (pulled > 0) _db.markTablesUpdated(_db.allTables);

      var pushed = 0;
      for (final spec in _tables) {
        try {
          pushed += await _push(spec, userId);
        } on PostgrestException {
          if (spec.name != 'auto_schedules') rethrow;
        }
      }
      // Detected -> transactions saling merujuk di remote; kirim ulang
      // detected_transactions setelah transactions ada.
      pushed += await _pushDetectedLinks(userId);

      final seen = _maxSeenSyncedAt;
      if (seen != null) {
        final prev = DateTime.tryParse(_prefs.getString(_cursorKey) ?? '');
        if (prev == null || seen.isAfter(prev)) {
          await _prefs.setString(_cursorKey, seen.toIso8601String());
        }
      }
      return SyncResult(pulled: pulled, pushed: pushed, failed: _failed);
    } on PostgrestException catch (e) {
      throw SyncException('Gagal sinkron: ${e.message}');
    } finally {
      await _db.customStatement('PRAGMA foreign_keys = ON');
      _running = false;
    }
  }

  // ─────────────────────────── PULL ───────────────────────────

  /// Cursor pull = waktu sync terakhir dikurangi [_cursorOverlap]. Overlap
  /// menoleransi selisih jam antar perangkat; menarik ulang baris yang sama
  /// aman karena penerapannya idempoten.
  static const _cursorOverlap = Duration(minutes: 2);
  int _failed = 0;

  /// synced_at (waktu server) terbesar yang terlihat pada pull sync ini.
  DateTime? _maxSeenSyncedAt;

  Future<String?> _pullCursor() async {
    final raw = _prefs.getString(_cursorKey);
    if (raw == null) return null;
    final t = DateTime.tryParse(raw);
    if (t == null) return null;

    // Bila Android Auto Backup memulihkan SharedPreferences saat reinstall APK
    // tetapi database SQLite lokal masih kosong (belum ada baris synced),
    // hapus cursor lama agar dilakukan full pull dari server.
    final hasSyncedData = await _db
        .customSelect(
          "SELECT 1 FROM categories WHERE sync_status = 'synced' "
          'UNION ALL '
          "SELECT 1 FROM wallets WHERE sync_status = 'synced' "
          'LIMIT 1',
        )
        .getSingleOrNull();
    if (hasSyncedData == null) {
      await _prefs.remove(_cursorKey);
      return null;
    }

    return t.subtract(_cursorOverlap).toUtc().toIso8601String();
  }

  Future<int> _pull(_TableSpec spec, String? cursor) async {
    final cols = await _localColumns(spec.name);
    var offset = 0;
    var count = 0;
    final tieBreaker = spec.isUserSettings ? 'user_id' : 'id';

    while (true) {
      var query = _supabase.from(spec.name).select();
      if (cursor != null) query = query.gt('synced_at', cursor);
      // Tie-breaker agar urutan antar halaman stabil.
      final rows = await query
          .order('synced_at', ascending: true)
          .order(tieBreaker, ascending: true)
          .range(offset, offset + _pageSize - 1);
      if (rows.isEmpty) break;

      for (final remote in rows) {
        final s = DateTime.tryParse('${remote['synced_at']}');
        if (s != null &&
            (_maxSeenSyncedAt == null || s.isAfter(_maxSeenSyncedAt!))) {
          _maxSeenSyncedAt = s.toUtc();
        }
      }

      await _db.transaction(() async {
        for (final remote in rows) {
          try {
            if (await _applyRemoteRow(spec, cols, remote)) count++;
          } on Exception catch (e) {
            _failed++;
            debugPrint('Sync: gagal menerapkan baris ${spec.name}: $e');
          } on TypeError catch (e) {
            // Baris remote dengan tipe/null tak terduga (cast gagal) juga diisolasi.
            // Satu baris bermasalah tidak boleh menggagalkan seluruh sync.
            _failed++;
            debugPrint('Sync: gagal menerapkan baris ${spec.name}: $e');
          }
        }
      });

      if (rows.length < _pageSize) break;
      offset += _pageSize;
    }
    return count;
  }

  Future<bool> _applyRemoteRow(
    _TableSpec spec,
    List<String> cols,
    Map<String, dynamic> remote,
  ) async {
    final data = Map<String, dynamic>.from(remote);
    if (spec.isUserSettings) {
      data['id'] = 'me';
    }
    data.remove('user_id');

    final id = data['id'] as String;
    final existing = await _db.customSelect(
      'SELECT sync_status FROM ${spec.name} WHERE id = ?',
      variables: [Variable<String>(id)],
    ).getSingleOrNull();
    if (existing != null && existing.read<String>('sync_status') == 'dirty') {
      return false; // perubahan lokal yang belum terkirim tidak ditimpa
    }

    // Notifikasi yang sama terdeteksi di dua perangkat (fingerprint unik tapi
    // id berbeda). Baris remote dianggap kanonik; salinan lokal yang belum
    // menjadi transaksi dibuang. Bila sudah dicatat jadi transaksi, simpan
    // lokal dan lewati baris remote.
    if (spec.name == 'detected_transactions' && data['fingerprint'] != null) {
      final dup = await _db.customSelect(
        'SELECT id, status FROM detected_transactions '
        'WHERE fingerprint = ? AND id != ?',
        variables: [
          Variable<String>(data['fingerprint'] as String),
          Variable<String>(id),
        ],
      ).getSingleOrNull();
      if (dup != null) {
        if (dup.read<String>('status') == 'recorded') return false;
        await _db.customStatement(
          'DELETE FROM detected_transactions WHERE id = ?',
          [dup.read<String>('id')],
        );
      }
    }

    final values = <String, Object?>{};
    for (final c in cols) {
      if (c == 'sync_status') continue;
      if (!data.containsKey(c)) continue;
      values[c] = _remoteToLocal(spec, c, data[c]);
    }
    values['sync_status'] = 'synced';

    final names = values.keys.toList();
    final placeholders = List.filled(names.length, '?').join(', ');
    final updates = names
        .where((c) => c != 'id')
        .map((c) => '$c = excluded.$c')
        .join(', ');
    await _db.customStatement(
      'INSERT INTO ${spec.name} (${names.join(', ')}) VALUES ($placeholders) '
      'ON CONFLICT(id) DO UPDATE SET $updates',
      names.map((n) => values[n]).toList(),
    );
    return true;
  }

  Object? _remoteToLocal(_TableSpec spec, String col, Object? v) {
    if (v == null) return null;
    if (spec.dateCols.contains(col)) {
      return DateTime.parse(v as String).millisecondsSinceEpoch ~/ 1000;
    }
    if (spec.boolCols.contains(col)) return (v as bool) ? 1 : 0;
    return v;
  }

  // ─────────────────────────── PUSH ───────────────────────────

  Future<int> _push(_TableSpec spec, String userId) async {
    // wallets: induk dulu, anak belakangan.
    final order = spec.name == 'wallets' ? 'ORDER BY parent_id IS NOT NULL' : '';

    // Ambil baris dirty dan tandai 'syncing' secara atomik. Bila user mengedit
    // baris itu saat upload berjalan, statusnya kembali 'dirty' dan tidak
    // ikut ditandai 'synced' di bawah (edit tidak hilang).
    final dirty = await _db.transaction(() async {
      final rows = await _db
          .customSelect(
            'SELECT * FROM ${spec.name} WHERE sync_status = ? $order',
            variables: [Variable<String>('dirty')],
          )
          .get();
      if (rows.isNotEmpty) {
        await _db.customStatement(
          "UPDATE ${spec.name} SET sync_status = 'syncing' "
          "WHERE sync_status = 'dirty'",
        );
      }
      return rows;
    });
    if (dirty.isEmpty) return 0;

    final pushedAt = DateTime.now().toUtc().toIso8601String();
    final payload = <Map<String, dynamic>>[];
    final ids = <String>[];
    for (final row in dirty) {
      final map = _localToRemote(spec, row.data, userId, pushedAt);
      // transaction_id ditunda sampai transactions terkirim.
      if (spec.name == 'detected_transactions') {
        map['transaction_id'] = null;
      }
      payload.add(map);
      ids.add(row.data['id'] as String);
    }

    final onConflict = spec.isUserSettings ? 'user_id' : 'id';
    var tableFailed = 0;
    try {
      for (var i = 0; i < payload.length; i += _batchSize) {
        final end = (i + _batchSize).clamp(0, payload.length);
        final chunkPayload = payload.sublist(i, end);
        final chunkIds = ids.sublist(i, end);
        final okIds = <String>[];

        try {
          await _supabase
              .from(spec.name)
              .upsert(chunkPayload, onConflict: onConflict);
          okIds.addAll(chunkIds);
        } on PostgrestException {
          // Isolasi baris yang ditolak supaya tidak memblokir yang lain.
          for (var j = 0; j < chunkPayload.length; j++) {
            try {
              await _supabase
                  .from(spec.name)
                  .upsert([chunkPayload[j]], onConflict: onConflict);
              okIds.add(chunkIds[j]);
            } on PostgrestException catch (e) {
              tableFailed++;
              debugPrint(
                  'Sync: baris ${spec.name}/${chunkIds[j]} ditolak: ${e.message}');
            }
          }
          // Semua gagal = kemungkinan masalah umum (auth/RLS/skema): lempar.
          if (okIds.isEmpty) rethrow;
        }

        if (okIds.isNotEmpty) {
          final marks = List.filled(okIds.length, '?').join(', ');
          await _db.customStatement(
            "UPDATE ${spec.name} SET sync_status = 'synced' "
            "WHERE id IN ($marks) AND sync_status = 'syncing'",
            okIds,
          );
          if (spec.name == 'detected_transactions') {
            _pushedDetectedIds.addAll(okIds);
          }
        }
      }
    } finally {
      // Yang gagal / belum terkirim kembali 'dirty' untuk dicoba lagi.
      await _db.customStatement(
        "UPDATE ${spec.name} SET sync_status = 'dirty' "
        "WHERE sync_status = 'syncing'",
      );
    }
    _failed += tableFailed;
    return payload.length - tableFailed;
  }

  /// ID detected_transactions yang dikirim pada sync ini; hanya baris ini yang
  /// perlu dikirim ulang dengan transaction_id-nya.
  final Set<String> _pushedDetectedIds = {};

  /// Kirim ulang detected_transactions yang sudah terhubung ke transaksi.
  Future<int> _pushDetectedLinks(String userId) async {
    final spec = _tables.firstWhere((t) => t.name == 'detected_transactions');
    final rows = await _db
        .customSelect(
          'SELECT * FROM detected_transactions '
          'WHERE transaction_id IS NOT NULL AND deleted_at IS NULL',
        )
        .get();
    // Hanya yang barusan didorong pada sync ini (status recorded) yang perlu
    // diperbarui dengan transaction_id-nya.
    final pushedAt = DateTime.now().toUtc().toIso8601String();
    final linkedRows = rows.where((r) =>
        r.data['status'] == 'recorded' &&
        _pushedDetectedIds.contains(r.data['id']));
    final linkedIds = [for (final r in linkedRows) r.data['id'] as String];
    final linked = [
      for (final r in linkedRows) _localToRemote(spec, r.data, userId, pushedAt),
    ];
    for (var i = 0; i < linked.length; i += _batchSize) {
      final end = (i + _batchSize).clamp(0, linked.length);
      try {
        await _supabase.from(spec.name).upsert(
              linked.sublist(i, end),
              onConflict: 'id',
            );
      } on PostgrestException catch (e) {
        // Jangan blokir sync; kembalikan ke dirty agar dikirim ulang nanti.
        debugPrint('Sync: gagal mengirim link detected: ${e.message}');
        _failed += end - i;
        final chunk = linkedIds.sublist(i, end);
        final marks = List.filled(chunk.length, '?').join(', ');
        await _db.customStatement(
          "UPDATE detected_transactions SET sync_status = 'dirty' "
          'WHERE id IN ($marks)',
          chunk,
        );
      }
    }
    return 0;
  }

  Map<String, dynamic> _localToRemote(
    _TableSpec spec,
    Map<String, dynamic> row,
    String userId,
    String pushedAt,
  ) {
    final out = <String, dynamic>{};
    row.forEach((col, v) {
      if (col == 'sync_status') return;
      if (spec.isUserSettings && col == 'id') return;
      if (v == null) {
        out[col] = null;
      } else if (spec.dateCols.contains(col)) {
        out[col] = DateTime.fromMillisecondsSinceEpoch(
          (v as int) * 1000,
          isUtc: true,
        ).toIso8601String();
      } else if (spec.boolCols.contains(col)) {
        out[col] = v == 1 || v == true;
      } else {
        out[col] = v;
      }
    });
    // Cap waktu push (bukan waktu edit lokal): cursor pull perangkat lain
    // berbasis updated_at, jadi baris yang diedit lama saat offline tetap
    // terlihat sebagai perubahan baru.
    if (out.containsKey('updated_at')) out['updated_at'] = pushedAt;
    out['user_id'] = userId;
    return out;
  }

  Future<List<String>> _localColumns(String table) async {
    final cached = _columnCache[table];
    if (cached != null) return cached;
    final rows = await _db.customSelect('PRAGMA table_info($table)').get();
    final cols = rows.map((r) => r.read<String>('name')).toList();
    _columnCache[table] = cols;
    return cols;
  }
}
