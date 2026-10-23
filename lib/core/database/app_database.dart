import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'finance_exception.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Saldo satu wallet yang dihitung dari ledger (bukan kolom tersimpan).
class WalletBalance {
  final String walletId;
  final double balance;
  const WalletBalance(this.walletId, this.balance);
}

@DriftDatabase(
  tables: [
    Categories,
    Wallets,
    DetectedTransactions,
    Transactions,
    WalletAllocations,
    Transfers,
    NotificationSources,
    BudgetLimits,
    SavingJars,
    SavingJarEntries,
    UserSettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Untuk test: database in-memory.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  Future<void> _ensureAutoSchedulesTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS auto_schedules (
        id TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        kind TEXT NOT NULL DEFAULT 'expense',
        amount REAL NOT NULL,
        day_of_month INTEGER NOT NULL,
        wallet_id TEXT NOT NULL REFERENCES wallets (id),
        to_wallet_id TEXT REFERENCES wallets (id),
        category_id TEXT REFERENCES categories (id),
        budget_id TEXT REFERENCES budget_limits (id),
        note TEXT,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        last_executed_period TEXT,
        last_executed_at INTEGER,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s', CURRENT_TIMESTAMP)),
        deleted_at INTEGER,
        sync_status TEXT NOT NULL DEFAULT 'dirty'
      )
    ''');
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_auto_schedules_day '
      'ON auto_schedules (day_of_month, is_enabled)',
    );
  }

  /// Index untuk query saldo (subquery per wallet), analitik, dan deduplikasi
  /// notifikasi. Idempotent (IF NOT EXISTS) sehingga aman dipanggil di
  /// onCreate, onUpgrade, maupun beforeOpen: pengguna lama ikut mendapatkannya.
  Future<void> _ensureIndexes() async {
    const statements = <String>[
      'CREATE INDEX IF NOT EXISTS idx_tx_wallet_date '
          'ON transactions (wallet_id, date)',
      'CREATE INDEX IF NOT EXISTS idx_tx_category '
          'ON transactions (category_id)',
      'CREATE INDEX IF NOT EXISTS idx_detected_status '
          'ON detected_transactions (status)',
      'CREATE INDEX IF NOT EXISTS idx_detected_dup '
          'ON detected_transactions (source_package, amount, type, detected_at)',
      'CREATE INDEX IF NOT EXISTS idx_transfers_from '
          'ON transfers (from_wallet_id)',
      'CREATE INDEX IF NOT EXISTS idx_transfers_to '
          'ON transfers (to_wallet_id)',
      'CREATE INDEX IF NOT EXISTS idx_jar_entries_wallet '
          'ON saving_jar_entries (wallet_id)',
      'CREATE INDEX IF NOT EXISTS idx_jar_entries_jar '
          'ON saving_jar_entries (jar_id)',
    ];
    for (final s in statements) {
      await customStatement(s);
    }
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _ensureIndexes();
          await _ensureAutoSchedulesTable();
        },
        // Tambahkan migrasi berikutnya di sini, mis.:
        //   if (from < 2) await m.addColumn(wallets, wallets.newColumn);
        // schemaVersion harus dinaikkan bersamaan; tanpa onUpgrade, Drift
        // akan melempar error pada pengguna lama saat versi dinaikkan.
        onUpgrade: (m, from, to) async {
          await _ensureAutoSchedulesTable();
          await _ensureIndexes();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await _ensureAutoSchedulesTable();
          await _ensureIndexes();
        },
      );

  /// Hapus PERMANEN seluruh data lokal. Dipakai saat akun yang login berbeda
  /// dari pemilik data lokal, agar data user lain tidak bocor / ter-upload.
  Future<void> wipeAllData() async {
    // PRAGMA foreign_keys tidak berefek di dalam transaksi, jadi diatur di luar.
    await customStatement('PRAGMA foreign_keys = OFF');
    try {
      await transaction(() async {
        await customStatement('DELETE FROM auto_schedules');
        for (final t in allTables) {
          await customStatement('DELETE FROM ${t.actualTableName}');
        }
      });
      markTablesUpdated(allTables);
    } finally {
      await customStatement('PRAGMA foreign_keys = ON');
    }
  }

  /// Pastikan saldo [walletId] cukup untuk mengeluarkan [needed]. Melempar
  /// [FinanceException] bila dompet tidak ditemukan atau saldo kurang.
  /// Panggil di dalam `transaction()` agar pengecekan dan penulisan atomik.
  Future<void> requireBalance(String walletId, double needed) async {
    final row = await customSelect(
      '''
      SELECT w.opening_balance
        + COALESCE((SELECT SUM(amount) FROM transactions t
            WHERE t.wallet_id = w.id AND t.type = 'income'
              AND t.deleted_at IS NULL), 0)
        - COALESCE((SELECT SUM(amount) FROM transactions t
            WHERE t.wallet_id = w.id AND t.type = 'expense'
              AND t.deleted_at IS NULL), 0)
        + COALESCE((SELECT SUM(amount) FROM transfers x
            WHERE x.to_wallet_id = w.id AND x.deleted_at IS NULL), 0)
        - COALESCE((SELECT SUM(amount + fee) FROM transfers x
            WHERE x.from_wallet_id = w.id AND x.deleted_at IS NULL), 0)
        - COALESCE((SELECT SUM(amount) FROM saving_jar_entries e
            WHERE e.wallet_id = w.id AND e.type = 'deposit'
              AND e.deleted_at IS NULL), 0)
        + COALESCE((SELECT SUM(amount) FROM saving_jar_entries e
            WHERE e.wallet_id = w.id AND e.type = 'withdraw'
              AND e.deleted_at IS NULL), 0)
        AS balance
      FROM wallets w
      WHERE w.id = ? AND w.deleted_at IS NULL
      ''',
      variables: [Variable.withString(walletId)],
    ).getSingleOrNull();
    if (row == null) throw const FinanceException('Dompet tidak ditemukan');
    final balance = row.read<double>('balance');
    // Toleransi 0.005 untuk galat pembulatan floating point.
    if (balance + 0.005 < needed) {
      throw const FinanceException('Saldo dompet tidak mencukupi');
    }
  }

  /// Saldo tiap wallet:
  /// opening_balance + pemasukan - pengeluaran + transfer masuk
  /// - transfer keluar - biaya transfer. Baris yang sudah dihapus
  /// (soft delete) diabaikan.
  Stream<List<WalletBalance>> watchWalletBalances() {
    return customSelect(
      '''
      SELECT w.id AS id,
        w.opening_balance
        + COALESCE((SELECT SUM(amount) FROM transactions t
            WHERE t.wallet_id = w.id AND t.type = 'income'
              AND t.deleted_at IS NULL), 0)
        - COALESCE((SELECT SUM(amount) FROM transactions t
            WHERE t.wallet_id = w.id AND t.type = 'expense'
              AND t.deleted_at IS NULL), 0)
        + COALESCE((SELECT SUM(amount) FROM transfers x
            WHERE x.to_wallet_id = w.id AND x.deleted_at IS NULL), 0)
        - COALESCE((SELECT SUM(amount + fee) FROM transfers x
            WHERE x.from_wallet_id = w.id AND x.deleted_at IS NULL), 0)
        - COALESCE((SELECT SUM(amount) FROM saving_jar_entries e
            WHERE e.wallet_id = w.id AND e.type = 'deposit'
              AND e.deleted_at IS NULL), 0)
        + COALESCE((SELECT SUM(amount) FROM saving_jar_entries e
            WHERE e.wallet_id = w.id AND e.type = 'withdraw'
              AND e.deleted_at IS NULL), 0)
        AS balance
      FROM wallets w
      WHERE w.deleted_at IS NULL
      ''',
      readsFrom: {wallets, transactions, transfers, savingJarEntries},
    ).watch().map(
          (rows) => [
            for (final r in rows)
              WalletBalance(r.read<String>('id'), r.read<double>('balance')),
          ],
        );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'moneta.sqlite'));
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    return NativeDatabase.createInBackground(file);
  });
}
