part of '../finance_repository.dart';

/// Anggaran bulanan per kategori.
extension FinanceBudgets on FinanceRepository {
  // ── Anggaran ──

  Stream<List<BudgetView>> watchBudgets(int month, int year) {
    final from = DateTime(year, month);
    final to = DateTime(year, month + 1);
    return _db
        .customSelect(
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
            Variable.withInt(FinanceRepository._s(from)),
            Variable.withInt(FinanceRepository._s(to)),
            Variable.withInt(month),
            Variable.withInt(year),
          ],
          readsFrom: {
            _db.budgetLimits,
            _db.transactions,
            _db.categories,
            _db.wallets,
          },
        )
        .watch()
        .map(
          (rows) => [
            for (final r in rows)
              BudgetView(
                r.read<String>('id'),
                r.readNullable<String>('category_id'),
                r.read<String>('name'),
                r.read<double>('lim'),
                r.read<double>('spent'),
              ),
          ],
        );
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
    final matches =
        await (_db.select(_db.budgetLimits)
              ..where(
                (b) =>
                    b.deletedAt.isNull() &
                    b.month.equals(month) &
                    b.year.equals(year) &
                    (categoryId == null
                        ? b.categoryId.isNull()
                        : b.categoryId.equals(categoryId)),
              )
              ..orderBy([(b) => OrderingTerm(expression: b.createdAt)]))
            .get();
    final budgetId =
        id ??
        (matches.isNotEmpty ? matches.first.id : FinanceRepository._uuid.v4());
    await _db.transaction(() async {
      final now = FinanceRepository._s(DateTime.now());
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
      await _db
          .into(_db.budgetLimits)
          .insertOnConflictUpdate(
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
    final now = FinanceRepository._s(DateTime.now());
    await _db.customUpdate(
      "UPDATE auto_schedules SET budget_id = NULL, updated_at = ?, sync_status = 'dirty' "
      'WHERE budget_id = ? AND deleted_at IS NULL',
      variables: [Variable.withInt(now), Variable.withString(id)],
      updates: {_db.budgetLimits},
    );
    await _softDelete(_db.budgetLimits, id);
  }
}
