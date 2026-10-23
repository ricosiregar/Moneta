part of '../finance_repository.dart';

/// Ringkasan & analitik periode.
extension FinanceAnalytics on FinanceRepository {
  // ── Ringkasan / analitik ──

  Stream<PeriodSummary> watchSummary(
    DateTime from,
    DateTime to, {
    String? walletId,
  }) {
    final whereWallet = walletId != null ? ' AND wallet_id = ?' : '';
    final vars = <Variable>[
      Variable.withInt(FinanceRepository._s(from)),
      Variable.withInt(FinanceRepository._s(to)),
      if (walletId != null) Variable.withString(walletId),
    ];
    return _db
        .customSelect(
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
        )
        .watchSingle()
        .map(
          (r) => PeriodSummary(
            r.read<double>('inc'),
            r.read<double>('exp'),
            r.read<int>('cnt'),
          ),
        );
  }

  Stream<List<CategoryTotal>> watchExpenseByCategory(
    DateTime from,
    DateTime to, {
    String? walletId,
  }) {
    final whereWallet = walletId != null ? ' AND t.wallet_id = ?' : '';
    final vars = <Variable>[
      Variable.withInt(FinanceRepository._s(from)),
      Variable.withInt(FinanceRepository._s(to)),
      if (walletId != null) Variable.withString(walletId),
    ];
    return _db
        .customSelect(
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
        )
        .watch()
        .map(
          (rows) => [
            for (final r in rows)
              CategoryTotal(
                r.read<String>('name'),
                r.read<double>('total'),
                categoryId: r.readNullable<String>('category_id'),
                icon: r.readNullable<String>('icon'),
                count: r.read<int>('cnt'),
              ),
          ],
        );
  }

  /// Total per hari (income, expense) untuk grafik, dari [from] sampai [to).
  Stream<List<(DateTime, double, double)>> watchDaily(
    DateTime from,
    DateTime to, {
    String? walletId,
  }) {
    final whereWallet = walletId != null ? ' AND wallet_id = ?' : '';
    final vars = <Variable>[
      Variable.withInt(FinanceRepository._s(from)),
      Variable.withInt(FinanceRepository._s(to)),
      if (walletId != null) Variable.withString(walletId),
    ];
    return _db
        .customSelect(
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
        )
        .watch()
        .map(
          (rows) => [
            for (final r in rows)
              (
                DateTime.parse(r.read<String>('day')),
                r.read<double>('inc'),
                r.read<double>('exp'),
              ),
          ],
        );
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
      Variable.withInt(FinanceRepository._s(from)),
      Variable.withInt(FinanceRepository._s(to)),
      if (categoryId != null) Variable.withString(categoryId),
      if (categoryId == null && categoryName != null) ...[
        Variable.withString(categoryName),
        Variable.withString(categoryName),
      ],
      if (walletId != null) Variable.withString(walletId),
    ];
    final rows = await _db
        .customSelect(
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
        )
        .get();
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
}
