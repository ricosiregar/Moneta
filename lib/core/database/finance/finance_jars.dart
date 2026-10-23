part of '../finance_repository.dart';

/// Celengan (Piggo).
extension FinanceJars on FinanceRepository {
  // ── Celengan (Piggo) ──

  Stream<List<JarView>> watchJars() {
    return (_db.select(_db.savingJars)
          ..where((j) => j.deletedAt.isNull())
          ..orderBy([(j) => OrderingTerm(expression: j.createdAt)]))
        .watch()
        .map(
          (rows) => [
            for (final j in rows)
              JarView(
                j.id,
                j.title,
                j.targetAmount,
                j.currentAmount,
                j.icon,
                j.targetDate,
              ),
          ],
        );
  }

  Future<void> addJar({
    required String title,
    required double target,
    DateTime? targetDate,
    String? icon,
  }) async {
    ensureValidAmount(target, label: 'Target');
    await _db
        .into(_db.savingJars)
        .insert(
          SavingJarsCompanion.insert(
            id: FinanceRepository._uuid.v4(),
            title: title.trim(),
            targetAmount: target,
            targetDate: Value(targetDate),
            icon: Value(icon),
          ),
        );
  }

  /// Hapus celengan beserta seluruh entrinya. Entri ikut di-soft-delete agar
  /// setoran yang sudah memotong saldo wallet kembali ke wallet (saldo dihitung
  /// dari entri yang belum dihapus).
  Future<void> deleteJar(String id) async {
    final now = FinanceRepository._s(DateTime.now());
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
      final jar =
          await (_db.select(_db.savingJars)
                ..where((j) => j.id.equals(jarId) & j.deletedAt.isNull()))
              .getSingleOrNull();
      if (jar == null) {
        throw const FinanceException('Celengan tidak ditemukan');
      }
      // Dana setoran berasal dari dompet; saldonya harus cukup.
      if (walletId != null) await _db.requireBalance(walletId, amount);
      final newAmount = jar.currentAmount + amount;
      await _db
          .into(_db.savingJarEntries)
          .insert(
            SavingJarEntriesCompanion.insert(
              id: FinanceRepository._uuid.v4(),
              jarId: jarId,
              amount: amount,
              type: 'deposit',
              walletId: Value(walletId),
              note: Value(note ?? 'Setor celengan: ${jar.title}'),
            ),
          );
      await (_db.update(
        _db.savingJars,
      )..where((j) => j.id.equals(jarId))).write(
        SavingJarsCompanion(
          currentAmount: Value(newAmount),
          isCompleted: Value(newAmount >= jar.targetAmount),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('dirty'),
        ),
      );
    });
  }
}
