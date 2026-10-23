part of '../finance_repository.dart';

/// Jadwal otomatis / auto-transfer (Budgeting Plan).
extension FinanceSchedules on FinanceRepository {
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
    final nowSec = FinanceRepository._s(now);
    final scheduleId = id ?? FinanceRepository._uuid.v4();
    final safeDay = dayOfMonth.clamp(1, 31);
    final cleanTitle = title.trim().isEmpty
        ? (kind == 'transfer' ? 'Auto-Transfer' : 'Pembayaran Otomatis')
        : title.trim();
    final cleanNote = (note == null || note.trim().isEmpty)
        ? null
        : note.trim();

    final existingRow = await _db
        .customSelect(
          'SELECT last_executed_period, last_executed_at, created_at '
          'FROM auto_schedules WHERE id = ?',
          variables: [Variable.withString(scheduleId)],
        )
        .getSingleOrNull();

    final currentPeriod = AutoScheduleView.periodKey(now);
    final maxDaysThisMonth = DateTime(now.year, now.month + 1, 0).day;
    final effectiveDay = safeDay.clamp(1, maxDaysThisMonth);

    String? lastPeriod = existingRow?.readNullable<String>(
      'last_executed_period',
    );
    final int? lastExecAt = existingRow?.readNullable<int>('last_executed_at');
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
    final nowSec = FinanceRepository._s(DateTime.now());
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
    final nowSec = FinanceRepository._s(DateTime.now());
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
    final nowSec = FinanceRepository._s(current);
    final period = AutoScheduleView.periodKey(current);

    final all = await getAutoSchedules();
    final target = all.where((s) => s.id == id).firstOrNull;
    if (target == null) return null;

    var ran = false;
    await _db.transaction(() async {
      // Cek ulang di dalam transaksi agar tidak ada eksekusi ganda.
      if (!force) {
        final lp = await _db
            .customSelect(
              'SELECT last_executed_period FROM auto_schedules WHERE id = ?',
              variables: [Variable.withString(id)],
            )
            .getSingleOrNull();
        if (lp?.readNullable<String>('last_executed_period') == period) return;
      }

      final balRow = await _db
          .customSelect(
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
          )
          .getSingleOrNull();

      final walletBalance = balRow?.read<double>('balance') ?? 0;
      if (walletBalance < target.amount) return;
      if (target.kind == 'transfer' &&
          target.toWalletId != null &&
          target.toWalletId != target.walletId) {
        await _db
            .into(_db.transfers)
            .insert(
              TransfersCompanion.insert(
                id: FinanceRepository._uuid.v4(),
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
        await _db
            .into(_db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: FinanceRepository._uuid.v4(),
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
}
