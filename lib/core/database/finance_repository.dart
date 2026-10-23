import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';
import 'finance_exception.dart';

// ── View models ────────────────────────────────────────────────────────────

class CategoryView {
  final String id;
  final String name;
  final String type; // income | expense
  final String? icon;
  const CategoryView(this.id, this.name, this.type, this.icon);
}

class FeedItem {
  final String id;
  final String kind; // income | expense | transfer
  final String title;
  final String category;
  final String? iconKey;
  final String wallet;
  final double amount;
  final DateTime date;
  final String? walletId;
  final String? toWalletId;
  final String? categoryId;
  const FeedItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.category,
    required this.iconKey,
    required this.wallet,
    required this.amount,
    required this.date,
    this.walletId,
    this.toWalletId,
    this.categoryId,
  });
}

class PeriodSummary {
  final double income;
  final double expense;
  final int count;
  const PeriodSummary(this.income, this.expense, this.count);
}

class CategoryTotal {
  final String name;
  final double total;
  final String? categoryId;
  final String? icon;
  final int count;
  const CategoryTotal(
    this.name,
    this.total, {
    this.categoryId,
    this.icon,
    this.count = 0,
  });
}

class BudgetView {
  final String id;
  final String? categoryId;
  final String categoryName;
  final double limit;
  final double spent;
  const BudgetView(
      this.id, this.categoryId, this.categoryName, this.limit, this.spent);
}

class JarView {
  final String id;
  final String title;
  final double target;
  final double saved;
  final String? icon;
  final DateTime? targetDate;
  const JarView(
      this.id, this.title, this.target, this.saved, this.icon, this.targetDate);
}

class AutoScheduleView {
  final String id;
  final String title;
  final String kind; // 'expense' | 'transfer'
  final double amount;
  final int dayOfMonth; // 1..31
  final String walletId;
  final String walletName;
  final String? toWalletId;
  final String? toWalletName;
  final String? categoryId;
  final String? categoryName;
  final String? categoryIcon;
  final String? budgetId;
  final String? note;
  final bool isEnabled;
  final String? lastExecutedPeriod; // 'YYYY-MM' atau 'SKIP:YYYY-MM'
  final DateTime? lastExecutedAt;

  const AutoScheduleView({
    required this.id,
    required this.title,
    required this.kind,
    required this.amount,
    required this.dayOfMonth,
    required this.walletId,
    required this.walletName,
    this.toWalletId,
    this.toWalletName,
    this.categoryId,
    this.categoryName,
    this.categoryIcon,
    this.budgetId,
    this.note,
    required this.isEnabled,
    this.lastExecutedPeriod,
    this.lastExecutedAt,
  });

  static String periodKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';

  bool isExecutedForMonth(DateTime now) =>
      lastExecutedPeriod == periodKey(now);

  bool isSkippedForMonth(DateTime now) =>
      lastExecutedPeriod == 'SKIP:${periodKey(now)}';

  int effectiveDayInMonth(DateTime now) {
    final maxDays = DateTime(now.year, now.month + 1, 0).day;
    return dayOfMonth.clamp(1, maxDays);
  }

  DateTime nextExecutionDate(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final thisMonthDay = effectiveDayInMonth(now);
    final thisMonthDate = DateTime(now.year, now.month, thisMonthDay);
    if (!isExecutedForMonth(now) &&
        !isSkippedForMonth(now) &&
        !thisMonthDate.isBefore(today)) {
      return thisMonthDate;
    }
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final nextMonthMax = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
    return DateTime(
      nextMonth.year,
      nextMonth.month,
      dayOfMonth.clamp(1, nextMonthMax),
    );
  }
}

/// Transaksi, kategori, anggaran, dan celengan. Semua perubahan ditandai
/// `dirty` agar ikut sinkron.
class FinanceRepository {
  FinanceRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  static int _s(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

  // ── Kategori ──

  static const _defaults = <(String, String, String)>[
    ('Makanan', 'expense', 'restaurant'),
    ('Transport', 'expense', 'bus'),
    ('Belanja', 'expense', 'bag'),
    ('Tagihan', 'expense', 'receipt'),
    ('Hiburan', 'expense', 'movie'),
    ('Kesehatan', 'expense', 'heart'),
    ('Lainnya', 'expense', 'more'),
    ('Gaji', 'income', 'wallet'),
    ('Bonus', 'income', 'gift'),
    ('Investasi', 'income', 'trend'),
    ('Penjualan', 'income', 'store'),
    ('Lainnya', 'income', 'more'),
  ];

  /// Isi kategori bawaan bila belum ada (dipanggil setelah login).
  ///
  /// ID dibuat deterministik (UUID v5 dari [userId] + tipe + nama) sehingga
  /// perangkat/instalasi berbeda untuk user yang sama menghasilkan ID yang
  /// sama dan tidak menggandakan kategori saat sinkron. Seed hanya berjalan
  /// bila tabel kategori kosong sama sekali (termasuk yang sudah dihapus),
  /// jadi kategori bawaan yang sengaja dihapus user tidak muncul lagi.
  Future<void> seedDefaultCategories({required String userId}) async {
    final existing = await (_db.select(_db.categories)..limit(1)).get();
    if (existing.isNotEmpty) return;
    await _db.batch((b) {
      b.insertAll(
        _db.categories,
        [
          for (final d in _defaults)
            CategoriesCompanion.insert(
              id: _uuid.v5(
                Namespace.url.value,
                'moneta-default-category:$userId:${d.$2}:${d.$1}',
              ),
              name: d.$1,
              type: d.$2,
              icon: Value(d.$3),
            ),
        ],
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Stream<List<CategoryView>> watchCategories([String? type]) {
    final q = _db.select(_db.categories)..where((c) => c.deletedAt.isNull());
    if (type != null) q.where((c) => c.type.equals(type));
    q.orderBy([(c) => OrderingTerm(expression: c.createdAt)]);
    return q.watch().map((rows) =>
        [for (final c in rows) CategoryView(c.id, c.name, c.type, c.icon)]);
  }

  Future<CategoryView> addCategory({
    required String name,
    required String type,
    String? icon,
    String? color,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            id: id,
            name: name.trim(),
            type: type,
            icon: Value(icon ?? 'more'),
            color: Value(color),
            syncStatus: const Value('dirty'),
          ),
        );
    return CategoryView(id, name.trim(), type, icon ?? 'more');
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    String? icon,
    String? color,
  }) async {
    await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: Value(name.trim()),
        icon: Value(icon),
        color: Value(color),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('dirty'),
      ),
    );
  }

  /// Hapus kategori. Anggaran milik kategori ini ikut dihapus (kalau tidak,
  /// tampil sebagai "Semua kategori") dan jadwal otomatis dilepas dari
  /// kategori. Transaksi lama tetap ada dan dihitung sebagai "Lainnya".
  Future<void> deleteCategory(String id) async {
    final now = _s(DateTime.now());
    await _db.transaction(() async {
      await _db.customUpdate(
        "UPDATE budget_limits SET deleted_at = ?, updated_at = ?, "
        "sync_status = 'dirty' WHERE category_id = ? AND deleted_at IS NULL",
        variables: [
          Variable.withInt(now),
          Variable.withInt(now),
          Variable.withString(id),
        ],
        updates: {_db.budgetLimits},
      );
      await _db.customUpdate(
        "UPDATE auto_schedules SET category_id = NULL, updated_at = ?, "
        "sync_status = 'dirty' WHERE category_id = ? AND deleted_at IS NULL",
        variables: [Variable.withInt(now), Variable.withString(id)],
        updates: {_db.budgetLimits},
      );
      await _softDelete(_db.categories, id);
    });
  }

  // ── Transaksi ──

  Future<void> addTransaction({
    required String walletId,
    String? categoryId,
    required String type,
    required double amount,
    String? title,
    String? note,
    DateTime? date,
  }) async {
    ensureValidAmount(amount);
    final cleanNote = (note == null || note.trim().isEmpty) ? null : note.trim();
    await _db.transaction(() async {
      // Pengeluaran tidak boleh melebihi saldo dompet (atomik dengan insert).
      if (type == 'expense') await _db.requireBalance(walletId, amount);
      await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              id: _uuid.v4(),
              walletId: walletId,
              categoryId: Value(categoryId),
              title: (title == null || title.trim().isEmpty)
                  ? (cleanNote ??
                      (type == 'income' ? 'Pemasukan' : 'Pengeluaran'))
                  : title.trim(),
              amount: amount,
              type: type,
              date: Value(date ?? DateTime.now()),
              note: Value(cleanNote),
            ),
          );
    });
  }

  Future<void> deleteTransaction(String id) => _softDelete(_db.transactions, id);
  Future<void> deleteTransfer(String id) async {
    final entry = await (_db.select(_db.savingJarEntries)
          ..where((e) => e.id.equals(id)))
        .getSingleOrNull();
    if (entry != null) {
      await _db.transaction(() async {
        await _softDelete(_db.savingJarEntries, id);
        final jar = await (_db.select(_db.savingJars)
              ..where((j) => j.id.equals(entry.jarId)))
            .getSingleOrNull();
        if (jar != null) {
          final delta = entry.type == 'deposit' ? -entry.amount : entry.amount;
          final newAmount =
              (jar.currentAmount + delta).clamp(0.0, double.infinity);
          await (_db.update(_db.savingJars)..where((j) => j.id.equals(jar.id)))
              .write(SavingJarsCompanion(
            currentAmount: Value(newAmount),
            isCompleted: Value(newAmount >= jar.targetAmount),
            updatedAt: Value(DateTime.now()),
            syncStatus: const Value('dirty'),
          ));
        }
      });
    } else {
      await _softDelete(_db.transfers, id);
    }
  }

  Future<void> _softDelete(TableInfo table, String id) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _db.customUpdate(
      "UPDATE ${table.actualTableName} SET deleted_at = ?, updated_at = ?, "
      "sync_status = 'dirty' WHERE id = ?",
      variables: [
        Variable.withInt(now),
        Variable.withInt(now),
        Variable.withString(id),
      ],
      updates: {table},
    );
  }

  Stream<List<FeedItem>> watchFeed({int limit = 500}) {
    return _db.customSelect(
      '''
      SELECT * FROM (
        SELECT t.id AS id, t.type AS kind, t.title AS title,
               COALESCE(c.name, 'Lainnya') AS category, c.icon AS icon,
               COALESCE(w.name, '-') AS wallet, t.amount AS amount, t.date AS date,
               t.wallet_id AS wallet_id, NULL AS to_wallet_id, t.category_id AS category_id
        FROM transactions t
        LEFT JOIN categories c ON c.id = t.category_id
        LEFT JOIN wallets w ON w.id = t.wallet_id
        WHERE t.deleted_at IS NULL
          AND t.wallet_id IN (SELECT id FROM wallets WHERE deleted_at IS NULL)
        UNION ALL
        SELECT x.id, 'transfer', COALESCE(x.note, 'Pindah uang'), 'Pindah Uang',
               'swap', fw.name || ' → ' || tw.name, x.amount, x.date,
               x.from_wallet_id AS wallet_id, x.to_wallet_id AS to_wallet_id, NULL AS category_id
        FROM transfers x
        JOIN wallets fw ON fw.id = x.from_wallet_id
        JOIN wallets tw ON tw.id = x.to_wallet_id
        WHERE x.deleted_at IS NULL
        UNION ALL
        SELECT e.id, 'transfer',
               COALESCE(e.note, CASE WHEN e.type = 'withdraw' THEN 'Tarik celengan: ' || j.title ELSE 'Setor celengan: ' || j.title END),
               'Pindah Uang',
               'savings',
               CASE WHEN e.type = 'withdraw' THEN j.title || ' → ' || COALESCE(w.name, 'Tunai') ELSE COALESCE(w.name, 'Tunai') || ' → ' || j.title END,
               e.amount,
               e.date,
               e.wallet_id AS wallet_id, NULL AS to_wallet_id, NULL AS category_id
        FROM saving_jar_entries e
        JOIN saving_jars j ON j.id = e.jar_id
        LEFT JOIN wallets w ON w.id = e.wallet_id
        WHERE e.deleted_at IS NULL AND j.deleted_at IS NULL
      ) ORDER BY date DESC LIMIT ?
      ''',
      variables: [Variable.withInt(limit)],
      readsFrom: {
        _db.transactions,
        _db.transfers,
        _db.categories,
        _db.wallets,
        _db.savingJarEntries,
        _db.savingJars,
      },
    ).watch().map((rows) => [
          for (final r in rows)
            FeedItem(
              id: r.read<String>('id'),
              kind: r.read<String>('kind'),
              title: r.read<String>('title'),
              category: r.read<String>('category'),
              iconKey: r.readNullable<String>('icon'),
              wallet: r.read<String>('wallet'),
              amount: r.read<double>('amount'),
              date: DateTime.fromMillisecondsSinceEpoch(
                  r.read<int>('date') * 1000),
              walletId: r.readNullable<String>('wallet_id'),
              toWalletId: r.readNullable<String>('to_wallet_id'),
              categoryId: r.readNullable<String>('category_id'),
            ),
        ]);
  }

  // ── Ringkasan / analitik ──

  Stream<PeriodSummary> watchSummary(DateTime from, DateTime to,
      {String? walletId}) {
    final whereWallet = walletId != null ? ' AND wallet_id = ?' : '';
    final vars = <Variable>[
      Variable.withInt(_s(from)),
      Variable.withInt(_s(to)),
      if (walletId != null) Variable.withString(walletId),
    ];
    return _db.customSelect(
      '''
      SELECT
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount END), 0) AS inc,
        COALESCE(SUM(CASE WHEN type = 'expense' THEN amount END), 0) AS exp,
        COUNT(*) AS cnt
      FROM transactions
      WHERE deleted_at IS NULL AND date >= ? AND date < ?$whereWallet
        AND wallet_id IN (SELECT id FROM wallets WHERE deleted_at IS NULL)
      ''',
      variables: vars,
      readsFrom: {_db.transactions, _db.wallets},
    ).watchSingle().map((r) => PeriodSummary(
          r.read<double>('inc'),
          r.read<double>('exp'),
          r.read<int>('cnt'),
        ));
  }

  Stream<List<CategoryTotal>> watchExpenseByCategory(
      DateTime from, DateTime to, {String? walletId}) {
    final whereWallet = walletId != null ? ' AND t.wallet_id = ?' : '';
    final vars = <Variable>[
      Variable.withInt(_s(from)),
      Variable.withInt(_s(to)),
      if (walletId != null) Variable.withString(walletId),
    ];
    return _db.customSelect(
      '''
      SELECT CASE WHEN c.id IS NULL THEN NULL ELSE t.category_id END AS category_id,
             COALESCE(c.name, 'Lainnya') AS name, c.icon AS icon,
             SUM(t.amount) AS total, COUNT(t.id) AS cnt
      FROM transactions t
      LEFT JOIN categories c ON c.id = t.category_id AND c.deleted_at IS NULL
      WHERE t.deleted_at IS NULL AND t.type = 'expense'
        AND t.wallet_id IN (SELECT id FROM wallets WHERE deleted_at IS NULL)
        AND t.date >= ? AND t.date < ?$whereWallet
      GROUP BY CASE WHEN c.id IS NULL THEN NULL ELSE t.category_id END,
               COALESCE(c.name, 'Lainnya'), c.icon
      ORDER BY total DESC
      ''',
      variables: vars,
      readsFrom: {_db.transactions, _db.categories, _db.wallets},
    ).watch().map((rows) => [
          for (final r in rows)
            CategoryTotal(
              r.read<String>('name'),
              r.read<double>('total'),
              categoryId: r.readNullable<String>('category_id'),
              icon: r.readNullable<String>('icon'),
              count: r.read<int>('cnt'),
            ),
        ]);
  }

  /// Total per hari (income, expense) untuk grafik, dari [from] sampai [to).
  Stream<List<(DateTime, double, double)>> watchDaily(
      DateTime from, DateTime to, {String? walletId}) {
    final whereWallet = walletId != null ? ' AND wallet_id = ?' : '';
    final vars = <Variable>[
      Variable.withInt(_s(from)),
      Variable.withInt(_s(to)),
      if (walletId != null) Variable.withString(walletId),
    ];
    return _db.customSelect(
      '''
      SELECT date(date, 'unixepoch', 'localtime') AS day,
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount END), 0) AS inc,
        COALESCE(SUM(CASE WHEN type = 'expense' THEN amount END), 0) AS exp
      FROM transactions
      WHERE deleted_at IS NULL AND date >= ? AND date < ?$whereWallet
        AND wallet_id IN (SELECT id FROM wallets WHERE deleted_at IS NULL)
      GROUP BY day ORDER BY day
      ''',
      variables: vars,
      readsFrom: {_db.transactions, _db.wallets},
    ).watch().map((rows) => [
          for (final r in rows)
            (
              DateTime.parse(r.read<String>('day')),
              r.read<double>('inc'),
              r.read<double>('exp'),
            ),
        ]);
  }

  /// Ambil riwayat transaksi per kategori untuk modal detail
  Future<List<FeedItem>> getTransactionsByCategory({
    required DateTime from,
    required DateTime to,
    String? categoryId,
    String? categoryName,
    String? walletId,
  }) async {
    final whereCat = categoryId != null
        ? ' AND t.category_id = ?'
        : (categoryName != null
            ? ' AND (c.name = ? OR (? = \'Lainnya\' AND c.id IS NULL))'
            : '');
    final whereWallet = walletId != null ? ' AND t.wallet_id = ?' : '';
    final vars = <Variable>[
      Variable.withInt(_s(from)),
      Variable.withInt(_s(to)),
      if (categoryId != null) Variable.withString(categoryId),
      if (categoryId == null && categoryName != null) ...[
        Variable.withString(categoryName),
        Variable.withString(categoryName),
      ],
      if (walletId != null) Variable.withString(walletId),
    ];
    final rows = await _db.customSelect(
      '''
      SELECT t.id AS id, t.type AS kind, t.title AS title,
             COALESCE(c.name, 'Lainnya') AS category, c.icon AS icon,
             COALESCE(w.name, '-') AS wallet, t.amount AS amount, t.date AS date,
             t.wallet_id AS wallet_id, t.category_id AS category_id
      FROM transactions t
      LEFT JOIN categories c ON c.id = t.category_id AND c.deleted_at IS NULL
      LEFT JOIN wallets w ON w.id = t.wallet_id
      WHERE t.deleted_at IS NULL AND t.type = 'expense'
        AND t.wallet_id IN (SELECT id FROM wallets WHERE deleted_at IS NULL)
        AND t.date >= ? AND t.date < ?$whereCat$whereWallet
      ORDER BY t.date DESC
      ''',
      variables: vars,
      readsFrom: {_db.transactions, _db.categories, _db.wallets},
    ).get();
    return [
      for (final r in rows)
        FeedItem(
          id: r.read<String>('id'),
          kind: r.read<String>('kind'),
          title: r.read<String>('title'),
          category: r.read<String>('category'),
          iconKey: r.readNullable<String>('icon'),
          wallet: r.read<String>('wallet'),
          amount: r.read<double>('amount'),
          date: DateTime.fromMillisecondsSinceEpoch(r.read<int>('date') * 1000),
          walletId: r.readNullable<String>('wallet_id'),
          toWalletId: null,
          categoryId: r.readNullable<String>('category_id'),
        ),
    ];
  }

  // ── Anggaran ──

  Stream<List<BudgetView>> watchBudgets(int month, int year) {
    final from = DateTime(year, month);
    final to = DateTime(year, month + 1);
    return _db.customSelect(
      '''
      SELECT b.id AS id, b.category_id AS category_id,
             COALESCE(c.name, 'Semua kategori') AS name,
             b.monthly_limit AS lim,
             COALESCE((SELECT SUM(t.amount) FROM transactions t
               WHERE t.deleted_at IS NULL AND t.type = 'expense'
                 AND t.wallet_id IN (SELECT id FROM wallets WHERE deleted_at IS NULL)
                  AND t.date >= ? AND t.date < ?
                 AND (b.category_id IS NULL OR t.category_id = b.category_id)), 0)
               AS spent
      FROM budget_limits b
      LEFT JOIN categories c ON c.id = b.category_id
      WHERE b.deleted_at IS NULL AND b.month = ? AND b.year = ?
      ORDER BY b.created_at
      ''',
      variables: [
        Variable.withInt(_s(from)),
        Variable.withInt(_s(to)),
        Variable.withInt(month),
        Variable.withInt(year),
      ],
      readsFrom: {
        _db.budgetLimits,
        _db.transactions,
        _db.categories,
        _db.wallets,
      },
    ).watch().map((rows) => [
          for (final r in rows)
            BudgetView(
              r.read<String>('id'),
              r.readNullable<String>('category_id'),
              r.read<String>('name'),
              r.read<double>('lim'),
              r.read<double>('spent'),
            ),
        ]);
  }

  Future<String> saveBudget({
    String? id,
    String? categoryId,
    required double limit,
    required int month,
    required int year,
  }) async {
    // Satu anggaran per kategori per bulan. Duplikat (mis. hasil sinkron dua
    // perangkat) tidak boleh membuat error: ambil yang tertua, buang sisanya.
    final matches = await (_db.select(_db.budgetLimits)
          ..where((b) =>
              b.deletedAt.isNull() &
              b.month.equals(month) &
              b.year.equals(year) &
              (categoryId == null
                  ? b.categoryId.isNull()
                  : b.categoryId.equals(categoryId)))
          ..orderBy([(b) => OrderingTerm(expression: b.createdAt)]))
        .get();
    final budgetId = id ?? (matches.isNotEmpty ? matches.first.id : _uuid.v4());
    await _db.transaction(() async {
      final now = _s(DateTime.now());
      for (final m in matches) {
        if (m.id == budgetId) continue;
        await _db.customUpdate(
          "UPDATE budget_limits SET deleted_at = ?, updated_at = ?, "
          "sync_status = 'dirty' WHERE id = ?",
          variables: [
            Variable.withInt(now),
            Variable.withInt(now),
            Variable.withString(m.id),
          ],
          updates: {_db.budgetLimits},
        );
      }
      await _db.into(_db.budgetLimits).insertOnConflictUpdate(
            BudgetLimitsCompanion(
              id: Value(budgetId),
              categoryId: Value(categoryId),
              monthlyLimit: Value(limit),
              month: Value(month),
              year: Value(year),
              updatedAt: Value(DateTime.now()),
              syncStatus: const Value('dirty'),
            ),
          );
    });
    return budgetId;
  }

  Future<void> deleteBudget(String id) async {
    final now = _s(DateTime.now());
    await _db.customUpdate(
      "UPDATE auto_schedules SET budget_id = NULL, updated_at = ?, sync_status = 'dirty' "
      'WHERE budget_id = ? AND deleted_at IS NULL',
      variables: [Variable.withInt(now), Variable.withString(id)],
      updates: {_db.budgetLimits},
    );
    await _softDelete(_db.budgetLimits, id);
  }

  // ── Jadwal Otomatis / Auto-Transfer (Budgeting Plan) ──

  static const _autoScheduleSelectSql = '''
    SELECT s.id AS id,
           s.title AS title,
           s.kind AS kind,
           s.amount AS amount,
           s.day_of_month AS day_of_month,
           s.wallet_id AS wallet_id,
           COALESCE(fw.name, 'Dompet') AS wallet_name,
           s.to_wallet_id AS to_wallet_id,
           tw.name AS to_wallet_name,
           s.category_id AS category_id,
           c.name AS category_name,
           c.icon AS category_icon,
           s.budget_id AS budget_id,
           s.note AS note,
           s.is_enabled AS is_enabled,
           s.last_executed_period AS last_executed_period,
           s.last_executed_at AS last_executed_at
    FROM auto_schedules s
    LEFT JOIN wallets fw ON fw.id = s.wallet_id
    LEFT JOIN wallets tw ON tw.id = s.to_wallet_id
    LEFT JOIN categories c ON c.id = s.category_id
    WHERE s.deleted_at IS NULL
    ORDER BY s.day_of_month ASC, s.created_at ASC
  ''';

  AutoScheduleView _mapAutoScheduleRow(QueryRow r) {
    final execAt = r.readNullable<int>('last_executed_at');
    return AutoScheduleView(
      id: r.read<String>('id'),
      title: r.read<String>('title'),
      kind: r.read<String>('kind'),
      amount: r.read<double>('amount'),
      dayOfMonth: r.read<int>('day_of_month'),
      walletId: r.read<String>('wallet_id'),
      walletName: r.read<String>('wallet_name'),
      toWalletId: r.readNullable<String>('to_wallet_id'),
      toWalletName: r.readNullable<String>('to_wallet_name'),
      categoryId: r.readNullable<String>('category_id'),
      categoryName: r.readNullable<String>('category_name'),
      categoryIcon: r.readNullable<String>('category_icon'),
      budgetId: r.readNullable<String>('budget_id'),
      note: r.readNullable<String>('note'),
      isEnabled: r.read<int>('is_enabled') == 1,
      lastExecutedPeriod: r.readNullable<String>('last_executed_period'),
      lastExecutedAt: execAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(execAt * 1000),
    );
  }

  Stream<List<AutoScheduleView>> watchAutoSchedules() {
    return _db
        .customSelect(
          _autoScheduleSelectSql,
          readsFrom: {
            _db.budgetLimits,
            _db.wallets,
            _db.categories,
            _db.transactions,
            _db.transfers,
          },
        )
        .watch()
        .map((rows) => [for (final r in rows) _mapAutoScheduleRow(r)]);
  }

  Future<List<AutoScheduleView>> getAutoSchedules() async {
    final rows = await _db.customSelect(_autoScheduleSelectSql).get();
    return [for (final r in rows) _mapAutoScheduleRow(r)];
  }

  Future<String> saveAutoSchedule({
    String? id,
    required String title,
    required String kind, // 'expense' | 'transfer'
    required double amount,
    required int dayOfMonth,
    required String walletId,
    String? toWalletId,
    String? categoryId,
    String? budgetId,
    String? note,
    bool isEnabled = true,
    bool executeNowForCurrentMonth = false,
  }) async {
    final now = DateTime.now();
    final nowSec = _s(now);
    final scheduleId = id ?? _uuid.v4();
    final safeDay = dayOfMonth.clamp(1, 31);
    final cleanTitle = title.trim().isEmpty
        ? (kind == 'transfer' ? 'Auto-Transfer' : 'Pembayaran Otomatis')
        : title.trim();
    final cleanNote =
        (note == null || note.trim().isEmpty) ? null : note.trim();

    final existingRow = await _db.customSelect(
      'SELECT last_executed_period, last_executed_at, created_at '
      'FROM auto_schedules WHERE id = ?',
      variables: [Variable.withString(scheduleId)],
    ).getSingleOrNull();

    final currentPeriod = AutoScheduleView.periodKey(now);
    final maxDaysThisMonth = DateTime(now.year, now.month + 1, 0).day;
    final effectiveDay = safeDay.clamp(1, maxDaysThisMonth);

    String? lastPeriod =
        existingRow?.readNullable<String>('last_executed_period');
    final int? lastExecAt =
        existingRow?.readNullable<int>('last_executed_at');
    final int createdAt =
        existingRow?.readNullable<int>('created_at') ?? nowSec;

    // Jika tanggal <= hari ini di bulan ini dan user memilih untuk TIDAK
    // mengeksekusi untuk bulan ini sekarang, tandai SKIP untuk periode bulan ini
    // agar baru berjalan mulai bulan depan. Jika tanggal > hari ini (misal besok),
    // biarkan null agar otomatis dieksekusi saat tanggalnya tiba.
    final canRunThisMonth = effectiveDay <= now.day;
    final shouldRunNow = executeNowForCurrentMonth && canRunThisMonth;
    if (lastPeriod != currentPeriod) {
      if (canRunThisMonth && !shouldRunNow) {
        lastPeriod = 'SKIP:$currentPeriod';
      } else if (!canRunThisMonth && lastPeriod == 'SKIP:$currentPeriod') {
        lastPeriod = null;
      }
    }

    await _db.customUpdate(
      '''
      INSERT INTO auto_schedules (
        id, title, kind, amount, day_of_month, wallet_id, to_wallet_id,
        category_id, budget_id, note, is_enabled, last_executed_period,
        last_executed_at, created_at, updated_at, deleted_at, sync_status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NULL, 'dirty')
      ON CONFLICT(id) DO UPDATE SET
        title = excluded.title,
        kind = excluded.kind,
        amount = excluded.amount,
        day_of_month = excluded.day_of_month,
        wallet_id = excluded.wallet_id,
        to_wallet_id = excluded.to_wallet_id,
        category_id = excluded.category_id,
        budget_id = excluded.budget_id,
        note = excluded.note,
        is_enabled = excluded.is_enabled,
        last_executed_period = excluded.last_executed_period,
        updated_at = excluded.updated_at,
        deleted_at = NULL,
        sync_status = 'dirty'
      ''',
      variables: [
        Variable.withString(scheduleId),
        Variable.withString(cleanTitle),
        Variable.withString(kind),
        Variable.withReal(amount),
        Variable.withInt(safeDay),
        Variable.withString(walletId),
        Variable<String>(toWalletId),
        Variable<String>(categoryId),
        Variable<String>(budgetId),
        Variable<String>(cleanNote),
        Variable.withInt(isEnabled ? 1 : 0),
        Variable<String>(lastPeriod),
        Variable<int>(lastExecAt),
        Variable.withInt(createdAt),
        Variable.withInt(nowSec),
      ],
      updates: {_db.budgetLimits},
    );

    if (shouldRunNow && lastPeriod != currentPeriod) {
      await executeAutoScheduleNow(scheduleId, now: now);
    }

    return scheduleId;
  }

  Future<void> toggleAutoSchedule(String id, bool isEnabled) async {
    final nowSec = _s(DateTime.now());
    await _db.customUpdate(
      "UPDATE auto_schedules SET is_enabled = ?, updated_at = ?, sync_status = 'dirty' WHERE id = ?",
      variables: [
        Variable.withInt(isEnabled ? 1 : 0),
        Variable.withInt(nowSec),
        Variable.withString(id),
      ],
      updates: {_db.budgetLimits},
    );
  }

  Future<void> deleteAutoSchedule(String id) async {
    final nowSec = _s(DateTime.now());
    await _db.customUpdate(
      "UPDATE auto_schedules SET deleted_at = ?, updated_at = ?, sync_status = 'dirty' WHERE id = ?",
      variables: [
        Variable.withInt(nowSec),
        Variable.withInt(nowSec),
        Variable.withString(id),
      ],
      updates: {_db.budgetLimits},
    );
  }

  /// Eksekusi satu jadwal otomatis sekarang juga dan catat transaksi / transfernya.
  ///
  /// Mengembalikan null bila saldo kurang, atau (kecuali [force]) bila jadwal
  /// sudah dieksekusi untuk periode bulan ini. [force] dipakai untuk aksi
  /// manual user ("Jalankan sekarang").
  Future<AutoScheduleView?> executeAutoScheduleNow(
    String id, {
    DateTime? now,
    bool force = false,
  }) async {
    final current = now ?? DateTime.now();
    final nowSec = _s(current);
    final period = AutoScheduleView.periodKey(current);

    final all = await getAutoSchedules();
    final target = all.where((s) => s.id == id).firstOrNull;
    if (target == null) return null;

    var ran = false;
    await _db.transaction(() async {
      // Cek ulang di dalam transaksi agar tidak ada eksekusi ganda.
      if (!force) {
        final lp = await _db.customSelect(
          'SELECT last_executed_period FROM auto_schedules WHERE id = ?',
          variables: [Variable.withString(id)],
        ).getSingleOrNull();
        if (lp?.readNullable<String>('last_executed_period') == period) return;
      }

      final balRow = await _db.customSelect(
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
        WHERE w.id = ? AND w.deleted_at IS NULL AND w.is_archived = 0
        ''',
        variables: [Variable.withString(target.walletId)],
      ).getSingleOrNull();

      final walletBalance = balRow?.read<double>('balance') ?? 0;
      if (walletBalance < target.amount) return;
      if (target.kind == 'transfer' &&
          target.toWalletId != null &&
          target.toWalletId != target.walletId) {
        await _db.into(_db.transfers).insert(
              TransfersCompanion.insert(
                id: _uuid.v4(),
                fromWalletId: target.walletId,
                toWalletId: target.toWalletId!,
                amount: target.amount,
                fee: const Value(0),
                date: Value(current),
                note: Value(
                  target.note ??
                      '${target.title} (Auto-Transfer Tgl ${target.dayOfMonth})',
                ),
              ),
            );
      } else {
        await _db.into(_db.transactions).insert(
              TransactionsCompanion.insert(
                id: _uuid.v4(),
                walletId: target.walletId,
                categoryId: Value(target.categoryId),
                title: target.title,
                amount: target.amount,
                type: 'expense',
                date: Value(current),
                note: Value(
                  target.note ??
                      'Otomatis: ${target.title} (Setiap Tgl ${target.dayOfMonth})',
                ),
              ),
            );
      }

      await _db.customUpdate(
        "UPDATE auto_schedules SET last_executed_period = ?, last_executed_at = ?, "
        "updated_at = ?, sync_status = 'dirty' WHERE id = ?",
        variables: [
          Variable.withString(period),
          Variable.withInt(nowSec),
          Variable.withInt(nowSec),
          Variable.withString(target.id),
        ],
        updates: {_db.budgetLimits, _db.transactions, _db.transfers},
      );
      ran = true;
    });

    if (!ran) return null;
    final updated = await getAutoSchedules();
    return updated.where((s) => s.id == id).firstOrNull;
  }

  /// Cek dan jalankan semua jadwal otomatis yang sudah jatuh tempo di bulan ini.
  Future<List<AutoScheduleView>> processDueAutoSchedules({
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    final all = await getAutoSchedules();
    final executed = <AutoScheduleView>[];

    for (final s in all) {
      if (!s.isEnabled) continue;
      if (s.isExecutedForMonth(current) || s.isSkippedForMonth(current)) {
        continue;
      }
      final effectiveDay = s.effectiveDayInMonth(current);
      if (current.day >= effectiveDay) {
        final done = await executeAutoScheduleNow(s.id, now: current);
        if (done != null) executed.add(done);
      }
    }
    return executed;
  }

  // ── Celengan (Piggo) ──

  Stream<List<JarView>> watchJars() {
    return (_db.select(_db.savingJars)
          ..where((j) => j.deletedAt.isNull())
          ..orderBy([(j) => OrderingTerm(expression: j.createdAt)]))
        .watch()
        .map((rows) => [
              for (final j in rows)
                JarView(j.id, j.title, j.targetAmount, j.currentAmount, j.icon,
                    j.targetDate),
            ]);
  }

  Future<void> addJar({
    required String title,
    required double target,
    DateTime? targetDate,
    String? icon,
  }) async {
    ensureValidAmount(target, label: 'Target');
    await _db.into(_db.savingJars).insert(SavingJarsCompanion.insert(
          id: _uuid.v4(),
          title: title.trim(),
          targetAmount: target,
          targetDate: Value(targetDate),
          icon: Value(icon),
        ));
  }

  /// Hapus celengan beserta seluruh entrinya. Entri ikut di-soft-delete agar
  /// setoran yang sudah memotong saldo wallet kembali ke wallet (saldo dihitung
  /// dari entri yang belum dihapus).
  Future<void> deleteJar(String id) async {
    final now = _s(DateTime.now());
    await _db.transaction(() async {
      await _db.customUpdate(
        "UPDATE saving_jar_entries SET deleted_at = ?, updated_at = ?, "
        "sync_status = 'dirty' WHERE jar_id = ? AND deleted_at IS NULL",
        variables: [
          Variable.withInt(now),
          Variable.withInt(now),
          Variable.withString(id),
        ],
        updates: {_db.savingJarEntries},
      );
      await _softDelete(_db.savingJars, id);
    });
  }

  /// Setor ke celengan; dicatat sebagai entri dan menambah `current_amount`.
  Future<void> deposit({
    required String jarId,
    required double amount,
    String? walletId,
    String? note,
  }) async {
    ensureValidAmount(amount, label: 'Nominal setoran');
    await _db.transaction(() async {
      final jar = await (_db.select(_db.savingJars)
            ..where((j) => j.id.equals(jarId) & j.deletedAt.isNull()))
          .getSingleOrNull();
      if (jar == null) {
        throw const FinanceException('Celengan tidak ditemukan');
      }
      // Dana setoran berasal dari dompet; saldonya harus cukup.
      if (walletId != null) await _db.requireBalance(walletId, amount);
      final newAmount = jar.currentAmount + amount;
      await _db.into(_db.savingJarEntries).insert(
            SavingJarEntriesCompanion.insert(
              id: _uuid.v4(),
              jarId: jarId,
              amount: amount,
              type: 'deposit',
              walletId: Value(walletId),
              note: Value(note ?? 'Setor celengan: ${jar.title}'),
            ),
          );
      await (_db.update(_db.savingJars)..where((j) => j.id.equals(jarId)))
          .write(SavingJarsCompanion(
        currentAmount: Value(newAmount),
        isCompleted: Value(newAmount >= jar.targetAmount),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('dirty'),
      ));
    });
  }
}
