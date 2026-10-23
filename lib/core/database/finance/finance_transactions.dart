part of '../finance_repository.dart';

/// Transaksi, pindah uang, dan feed aktivitas.
extension FinanceTransactions on FinanceRepository {
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
    final cleanNote = (note == null || note.trim().isEmpty)
        ? null
        : note.trim();
    await _db.transaction(() async {
      // Pengeluaran tidak boleh melebihi saldo dompet (atomik dengan insert).
      if (type == 'expense') await _db.requireBalance(walletId, amount);
      await _db
          .into(_db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: FinanceRepository._uuid.v4(),
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

  Future<void> deleteTransaction(String id) =>
      _softDelete(_db.transactions, id);
  Future<void> deleteTransfer(String id) async {
    final entry = await (_db.select(
      _db.savingJarEntries,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    if (entry != null) {
      await _db.transaction(() async {
        await _softDelete(_db.savingJarEntries, id);
        final jar = await (_db.select(
          _db.savingJars,
        )..where((j) => j.id.equals(entry.jarId))).getSingleOrNull();
        if (jar != null) {
          final delta = entry.type == 'deposit' ? -entry.amount : entry.amount;
          final newAmount = (jar.currentAmount + delta).clamp(
            0.0,
            double.infinity,
          );
          await (_db.update(
            _db.savingJars,
          )..where((j) => j.id.equals(jar.id))).write(
            SavingJarsCompanion(
              currentAmount: Value(newAmount),
              isCompleted: Value(newAmount >= jar.targetAmount),
              updatedAt: Value(DateTime.now()),
              syncStatus: const Value('dirty'),
            ),
          );
        }
      });
    } else {
      await _softDelete(_db.transfers, id);
    }
  }

  Stream<List<FeedItem>> watchFeed({int limit = 500}) {
    return _db
        .customSelect(
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
        )
        .watch()
        .map(
          (rows) => [
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
                  r.read<int>('date') * 1000,
                ),
                walletId: r.readNullable<String>('wallet_id'),
                toWalletId: r.readNullable<String>('to_wallet_id'),
                categoryId: r.readNullable<String>('category_id'),
              ),
          ],
        );
  }
}
