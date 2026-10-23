import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'app_database.dart';
import 'finance_exception.dart';

part 'finance/finance_views.dart';
part 'finance/finance_categories.dart';
part 'finance/finance_transactions.dart';
part 'finance/finance_analytics.dart';
part 'finance/finance_budgets.dart';
part 'finance/finance_schedules.dart';
part 'finance/finance_jars.dart';

/// Transaksi, kategori, anggaran, dan celengan. Semua perubahan ditandai
/// `dirty` agar ikut sinkron.
class FinanceRepository {
  FinanceRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  static int _s(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

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
}
