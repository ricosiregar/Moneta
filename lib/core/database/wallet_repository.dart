import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';

/// Wallet beserta saldo hasil hitung ledger.
class WalletView {
  final String id;
  final String name;
  final String type;
  final String? parentId;
  final String? purpose;
  final bool isIncomeSource;
  final double openingBalance;
  final double balance;
  const WalletView({
    required this.id,
    required this.name,
    required this.type,
    required this.parentId,
    required this.purpose,
    required this.isIncomeSource,
    required this.openingBalance,
    required this.balance,
  });
}

/// Satu aturan alokasi (persen) dari wallet sumber ke wallet anak.
class AllocationView {
  final String id;
  final String targetWalletId;
  final double? percent;
  final double? fixedAmount;
  const AllocationView(this.id, this.targetWalletId, this.percent, this.fixedAmount);
}

/// Akses data wallet, alokasi, dan transfer. Semua perubahan menandai baris
/// sebagai `dirty` agar ikut terkirim saat sinkronisasi.
class WalletRepository {
  WalletRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ── Baca ──

  Stream<List<WalletView>> watchWallets() {
    return _db.customSelect(
      '''
      SELECT w.id, w.name, w.type, w.parent_id, w.purpose,
        w.is_income_source, w.opening_balance, w.sort_order,
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
      WHERE w.deleted_at IS NULL AND w.is_archived = 0
      ORDER BY w.sort_order, w.created_at
      ''',
      readsFrom: {
        _db.wallets,
        _db.transactions,
        _db.transfers,
        _db.savingJarEntries,
      },
    ).watch().map((rows) => [
          for (final r in rows)
            WalletView(
              id: r.read<String>('id'),
              name: r.read<String>('name'),
              type: r.read<String>('type'),
              parentId: r.readNullable<String>('parent_id'),
              purpose: r.readNullable<String>('purpose'),
              isIncomeSource: r.read<int>('is_income_source') == 1,
              openingBalance: r.read<double>('opening_balance'),
              balance: r.read<double>('balance'),
            ),
        ]);
  }

  Future<List<AllocationView>> getAllocations(String sourceWalletId) async {
    final rows = await (_db.select(_db.walletAllocations)
          ..where((a) =>
              a.sourceWalletId.equals(sourceWalletId) & a.deletedAt.isNull())
          ..orderBy([(a) => OrderingTerm(expression: a.sortOrder)]))
        .get();
    return [
      for (final a in rows)
        AllocationView(a.id, a.targetWalletId, a.percent, a.fixedAmount),
    ];
  }

  // ── Wallet ──

  Future<void> saveWallet({
    String? id,
    required String name,
    required String type,
    String? parentId,
    String? purpose,
    bool isIncomeSource = false,
    double openingBalance = 0,
  }) async {
    final now = DateTime.now();
    final walletId = id ?? _uuid.v4();
    await _db.into(_db.wallets).insertOnConflictUpdate(
          WalletsCompanion(
            id: Value(walletId),
            name: Value(name.trim()),
            type: Value(type),
            parentId: Value(parentId),
            purpose: Value(
                (purpose == null || purpose.trim().isEmpty) ? null : purpose.trim()),
            isIncomeSource: Value(isIncomeSource),
            openingBalance: Value(openingBalance),
            updatedAt: Value(now),
            syncStatus: const Value('dirty'),
          ),
        );
  }

  /// Buat atau update wallet induk, dan sekaligus buatkan dompet anak dari ekosistemnya.
  Future<void> saveWalletWithEcosystemChildren({
    String? id,
    required String name,
    required String type,
    String? parentId,
    String? purpose,
    bool isIncomeSource = false,
    double openingBalance = 0,
    required List<({String name, String type, String purpose, double openingBalance})> ecosystemChildren,
  }) async {
    final now = DateTime.now();
    final walletId = id ?? _uuid.v4();
    await _db.transaction(() async {
      await _db.into(_db.wallets).insertOnConflictUpdate(
            WalletsCompanion(
              id: Value(walletId),
              name: Value(name.trim()),
              type: Value(type),
              parentId: Value(parentId),
              purpose: Value(
                  (purpose == null || purpose.trim().isEmpty) ? null : purpose.trim()),
              isIncomeSource: Value(isIncomeSource),
              openingBalance: Value(openingBalance),
              updatedAt: Value(now),
              syncStatus: const Value('dirty'),
            ),
          );

      var order = 1;
      for (final child in ecosystemChildren) {
        await _db.into(_db.wallets).insert(
              WalletsCompanion.insert(
                id: _uuid.v4(),
                name: child.name.trim(),
                type: child.type,
                parentId: Value(walletId),
                purpose: Value(child.purpose),
                isIncomeSource: const Value(false),
                openingBalance: Value(child.openingBalance),
                sortOrder: Value(order++),
                updatedAt: Value(now),
                syncStatus: const Value('dirty'),
              ),
            );
      }
    });
  }

  /// Soft delete. Wallet anak dilepas dari induknya.
  Future<void> deleteWallet(String id) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.wallets)..where((w) => w.parentId.equals(id))).write(
        WalletsCompanion(
          parentId: const Value(null),
          updatedAt: Value(now),
          syncStatus: const Value('dirty'),
        ),
      );
      await (_db.update(_db.wallets)..where((w) => w.id.equals(id))).write(
        WalletsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncStatus: const Value('dirty'),
        ),
      );
    });
  }

  // ── Alokasi ──

  /// Ganti seluruh aturan alokasi persen untuk [sourceWalletId].
  /// [percents] : walletId anak -> persen (nilai <= 0 diabaikan).
  Future<void> saveAllocations(
    String sourceWalletId,
    Map<String, double> percents,
  ) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(_db.walletAllocations)
            ..where((a) =>
                a.sourceWalletId.equals(sourceWalletId) & a.deletedAt.isNull()))
          .write(WalletAllocationsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncStatus: const Value('dirty'),
      ));
      var order = 0;
      for (final e in percents.entries) {
        if (e.value <= 0) continue;
        await _db.into(_db.walletAllocations).insert(
              WalletAllocationsCompanion.insert(
                id: _uuid.v4(),
                sourceWalletId: sourceWalletId,
                targetWalletId: e.key,
                percent: Value(e.value),
                sortOrder: Value(order++),
              ),
            );
      }
    });
  }

  // ── Transfer ──

  Future<void> createTransfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    double fee = 0,
    String? note,
    String? allocationId,
  }) async {
    await _db.into(_db.transfers).insert(
          TransfersCompanion.insert(
            id: _uuid.v4(),
            fromWalletId: fromWalletId,
            toWalletId: toWalletId,
            amount: amount,
            fee: Value(fee),
            note: Value((note == null || note.trim().isEmpty) ? null : note.trim()),
            allocationId: Value(allocationId),
          ),
        );
  }

  /// Bagi [amount] dari wallet sumber ke anak sesuai aturan alokasi
  /// (satu transaksi database).
  Future<void> distribute({
    required String sourceWalletId,
    required double amount,
  }) async {
    final rules = await getAllocations(sourceWalletId);
    await _db.transaction(() async {
      for (final r in rules) {
        final share = r.fixedAmount ?? (amount * (r.percent ?? 0) / 100);
        if (share <= 0) continue;
        await createTransfer(
          fromWalletId: sourceWalletId,
          toWalletId: r.targetWalletId,
          amount: share.roundToDouble(),
          note: 'Pembagian gaji',
          allocationId: r.id,
        );
      }
    });
  }

  /// Simpan aturan alokasi dan sekaligus eksekusi pemindahan saldo dari dompet
  /// sumber ke dompet-dompet anak sesuai persentase dalam satu transaksi database.
  Future<void> distributeAllocations({
    required String sourceWalletId,
    required Map<String, double> percents,
    required double baseAmount,
  }) async {
    await _db.transaction(() async {
      await saveAllocations(sourceWalletId, percents);
      final rules = await getAllocations(sourceWalletId);
      final ruleMap = {for (final r in rules) r.targetWalletId: r};

      for (final e in percents.entries) {
        final pct = e.value;
        if (pct <= 0) continue;
        final share = (baseAmount * pct / 100).roundToDouble();
        if (share <= 0) continue;
        final rule = ruleMap[e.key];
        await createTransfer(
          fromWalletId: sourceWalletId,
          toWalletId: e.key,
          amount: share,
          note:
              'Alokasi ${pct == pct.roundToDouble() ? pct.round() : pct}% dari dompet parent',
          allocationId: rule?.id,
        );
      }
    });
  }
}
