import 'package:drift/drift.dart' show Variable;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';

/// Hasil satu kali sinkronisasi.
class SyncResult {
  final int pulled;
  final int pushed;
  const SyncResult({required this.pulled, required this.pushed});
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

  static const _cursorKey = 'sync_last_synced_at';
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
      final startedAt = DateTime.now().toUtc();
      final cursor = _prefs.getString(_cursorKey);

      var pulled = 0;
      for (final spec in _tables) {
        try {
          pulled += await _pull(spec, cursor);
        } on PostgrestException {
          if (spec.name != 'auto_schedules') rethrow;
        }
      }

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

      await _prefs.setString(_cursorKey, startedAt.toIso8601String());
      return SyncResult(pulled: pulled, pushed: pushed);
    } on PostgrestException catch (e) {
      throw SyncException('Gagal sinkron: ${e.message}');
    } finally {
      await _db.customStatement('PRAGMA foreign_keys = ON');
      _running = false;
    }
  }

  // ─────────────────────────── PULL ───────────────────────────

  Future<int> _pull(_TableSpec spec, String? cursor) async {
    final cols = await _localColumns(spec.name);
    var offset = 0;
    var count = 0;

    while (true) {
      var query = _supabase.from(spec.name).select();
      if (cursor != null) query = query.gt('updated_at', cursor);
      final rows = await query
          .order('updated_at', ascending: true)
          .range(offset, offset + _pageSize - 1);
      if (rows.isEmpty) break;

      await _db.transaction(() async {
        for (final remote in rows) {
          if (await _applyRemoteRow(spec, cols, remote)) count++;
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
    final dirty = await _db
        .customSelect(
          'SELECT * FROM ${spec.name} WHERE sync_status = ? $order',
          variables: [Variable<String>('dirty')],
        )
        .get();
    if (dirty.isEmpty) return 0;

    final payload = <Map<String, dynamic>>[];
    final ids = <String>[];
    for (final row in dirty) {
      final map = _localToRemote(spec, row.data, userId);
      // transaction_id ditunda sampai transactions terkirim.
      if (spec.name == 'detected_transactions') {
        map['transaction_id'] = null;
      }
      payload.add(map);
      ids.add(row.data['id'] as String);
    }

    for (var i = 0; i < payload.length; i += _batchSize) {
      final end = (i + _batchSize).clamp(0, payload.length);
      await _supabase.from(spec.name).upsert(
            payload.sublist(i, end),
            onConflict: spec.isUserSettings ? 'user_id' : 'id',
          );
    }

    final marks = List.filled(ids.length, '?').join(', ');
    await _db.customStatement(
      "UPDATE ${spec.name} SET sync_status = 'synced' WHERE id IN ($marks)",
      ids,
    );
    return payload.length;
  }

  /// Kirim ulang detected_transactions yang sudah terhubung ke transaksi.
  Future<int> _pushDetectedLinks(String userId) async {
    final spec = _tables.firstWhere((t) => t.name == 'detected_transactions');
    final rows = await _db
        .customSelect(
          'SELECT * FROM detected_transactions '
          'WHERE transaction_id IS NOT NULL AND deleted_at IS NULL',
        )
        .get();
    // Hanya yang barusan didorong (status recorded) yang perlu diperbarui.
    final linked = rows
        .where((r) => r.data['status'] == 'recorded')
        .map((r) => _localToRemote(spec, r.data, userId))
        .toList();
    for (var i = 0; i < linked.length; i += _batchSize) {
      final end = (i + _batchSize).clamp(0, linked.length);
      await _supabase.from(spec.name).upsert(
            linked.sublist(i, end),
            onConflict: 'id',
          );
    }
    return 0;
  }

  Map<String, dynamic> _localToRemote(
    _TableSpec spec,
    Map<String, dynamic> row,
    String userId,
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
