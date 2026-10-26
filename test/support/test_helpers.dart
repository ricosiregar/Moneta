import 'package:drift/native.dart';
import 'package:moneta/core/database/app_database.dart';
import 'package:moneta/core/database/wallet_repository.dart';

/// Database in-memory baru (skema + index + auto_schedules lewat beforeOpen).
AppDatabase newTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

/// Buat wallet bertipe cash dengan saldo awal [opening]; kembalikan id-nya.
Future<String> addWallet(
  WalletRepository repo,
  String id, {
  double opening = 0,
}) async {
  await repo.saveWallet(
    id: id,
    name: id,
    type: 'cash',
    openingBalance: opening,
  );
  return id;
}

/// Saldo hasil hitung ledger untuk wallet [id].
Future<double> balanceOf(WalletRepository repo, String id) async {
  final wallets = await repo.watchWallets().first;
  return wallets.firstWhere((w) => w.id == id).balance;
}

/// Jumlah baris aktif (belum soft-delete) pada [table].
Future<int> activeCount(AppDatabase db, String table) async {
  final r = await db
      .customSelect('SELECT COUNT(*) AS c FROM $table WHERE deleted_at IS NULL')
      .getSingle();
  return r.read<int>('c');
}

/// Jumlah seluruh baris pada [table] (termasuk yang soft-delete).
Future<int> totalCount(AppDatabase db, String table) async {
  final r =
      await db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle();
  return r.read<int>('c');
}
