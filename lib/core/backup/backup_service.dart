import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';

/// Ekspor / impor / hapus data lokal (Drift).
///
/// Format JSON memakai nilai mentah database lokal (tanggal = epoch detik),
/// sehingga pemulihan bersifat lossless. Data yang diimpor ditandai `dirty`
/// agar ikut tersinkron ke cloud.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  /// Urut sesuai dependensi foreign key.
  static const _tables = [
    'categories',
    'wallets',
    'detected_transactions',
    'transactions',
    'wallet_allocations',
    'transfers',
    'notification_sources',
    'budget_limits',
    'auto_schedules',
    'saving_jars',
    'saving_jar_entries',
  ];

  static const _format = 'montrack-backup';
  static const _version = 1;

  // ── Ekspor ──

  Future<String> buildJson() async {
    final tables = <String, List<Map<String, Object?>>>{};
    for (final t in _tables) {
      final rows = await _db
          .customSelect('SELECT * FROM $t WHERE deleted_at IS NULL')
          .get();
      tables[t] = [
        for (final r in rows)
          Map<String, Object?>.from(r.data)..remove('sync_status'),
      ];
    }
    return jsonEncode({
      'format': _format,
      'version': _version,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'tables': tables,
    });
  }

  Future<String> buildCsv() async {
    final rows = await _db.customSelect('''
      SELECT t.date, t.type, t.amount, t.title, t.note,
             w.name AS wallet, c.name AS category
      FROM transactions t
      LEFT JOIN wallets w ON w.id = t.wallet_id
      LEFT JOIN categories c ON c.id = t.category_id
      WHERE t.deleted_at IS NULL
      ORDER BY t.date DESC
    ''').get();

    String esc(Object? v) {
      final s = v?.toString() ?? '';
      return (s.contains(',') || s.contains('"') || s.contains('\n'))
          ? '"${s.replaceAll('"', '""')}"'
          : s;
    }

    final buf = StringBuffer('Tanggal,Jenis,Nominal,Judul,Dompet,Kategori,Catatan\n');
    for (final r in rows) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        r.read<int>('date') * 1000,
      ).toIso8601String();
      buf.writeln([
        date,
        r.read<String>('type'),
        r.read<double>('amount'),
        r.read<String>('title'),
        r.readNullable<String>('wallet'),
        r.readNullable<String>('category'),
        r.readNullable<String>('note'),
      ].map(esc).join(','));
    }
    return buf.toString();
  }

  Future<void> shareJson() => _share('montrack-backup.json', buildJson);
  Future<void> shareCsv() => _share('montrack-transaksi.csv', buildCsv);

  Future<void> _share(String name, Future<String> Function() build) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsString(await build());
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  // ── Impor ──

  /// Mengembalikan jumlah baris yang dipulihkan.
  Future<int> importJson(String source) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } catch (_) {
      throw const FormatException('Berkas bukan JSON yang valid');
    }
    if (decoded is! Map || decoded['format'] != _format) {
      throw const FormatException('Bukan berkas cadangan MonTrack');
    }
    final tables = decoded['tables'];
    if (tables is! Map) throw const FormatException('Isi cadangan rusak');

    var count = 0;
    await _db.customStatement('PRAGMA foreign_keys = OFF');
    try {
      await _db.transaction(() async {
        for (final t in _tables) {
          final rows = tables[t];
          if (rows is! List) continue;
          final cols = (await _db.customSelect('PRAGMA table_info($t)').get())
              .map((r) => r.read<String>('name'))
              .toSet();
          for (final raw in rows) {
            if (raw is! Map) continue;
            final values = <String, Object?>{
              for (final e in raw.entries)
                if (cols.contains(e.key)) e.key as String: e.value,
            };
            if (values['id'] == null) continue;
            values['sync_status'] = 'dirty';
            final names = values.keys.toList();
            final updates = names
                .where((c) => c != 'id')
                .map((c) => '$c = excluded.$c')
                .join(', ');
            await _db.customStatement(
              'INSERT INTO $t (${names.join(', ')}) '
              'VALUES (${List.filled(names.length, '?').join(', ')}) '
              'ON CONFLICT(id) DO UPDATE SET $updates',
              names.map((n) => values[n]).toList(),
            );
            count++;
          }
        }
      });
    } finally {
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }
    return count;
  }

  // ── Hapus semua ──

  /// Soft delete semua data (ditandai dirty) sehingga penghapusan ikut
  /// tersinkron; kalau hanya dihapus lokal, sinkron berikutnya menariknya lagi.
  Future<void> clearAll() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _db.transaction(() async {
      for (final t in _tables) {
        await _db.customUpdate(
          "UPDATE $t SET deleted_at = ?, updated_at = ?, sync_status = 'dirty' "
          'WHERE deleted_at IS NULL',
          variables: [Variable.withInt(now), Variable.withInt(now)],
        );
      }
    });
  }
}
