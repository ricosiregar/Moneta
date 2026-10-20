import 'package:drift/drift.dart';

/// Kolom bersama untuk semua tabel yang ikut sinkron ke Supabase.
///
/// - [id] dibuat di klien (UUID v4) sehingga data bisa dibuat saat offline.
/// - [deletedAt] dipakai untuk soft delete supaya penghapusan ikut tersinkron.
/// - [syncStatus] hanya ada di lokal: `dirty` (perlu dikirim) / `synced`.
/// - `user_id` sengaja tidak disimpan lokal; diisi oleh SyncService saat push.
mixin SyncColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('dirty'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table with SyncColumns {
  TextColumn get name => text()();

  /// 'income' | 'expense'
  TextColumn get type => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
}

class Wallets extends Table with SyncColumns {
  TextColumn get name => text()();

  /// 'cash' | 'bank' | 'e_wallet'
  TextColumn get type => text()();

  /// Wallet induk (maks. 1 level). Null = wallet induk / berdiri sendiri.
  TextColumn get parentId => text().nullable().references(Wallets, #id)();
  TextColumn get purpose => text().nullable()();
  BoolColumn get isIncomeSource =>
      boolean().withDefault(const Constant(false))();
  RealColumn get openingBalance => real().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
}

class DetectedTransactions extends Table with SyncColumns {
  TextColumn get walletId => text().nullable().references(Wallets, #id)();
  TextColumn get sourcePackage => text().nullable()();
  RealColumn get amount => real()();

  /// 'income' | 'expense'
  TextColumn get type => text()();
  TextColumn get merchant => text().nullable()();
  DateTimeColumn get detectedAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Hash unik notifikasi untuk mencegah duplikat.
  TextColumn get fingerprint => text().unique()();

  /// 'pending' | 'recorded' | 'ignored' | 'moved'
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get transactionId => text().nullable()();
}

class Transactions extends Table with SyncColumns {
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get title => text()();
  RealColumn get amount => real()();

  /// 'income' | 'expense'
  TextColumn get type => text()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get note => text().nullable()();
  TextColumn get receiptImageUrl => text().nullable()();

  /// 'manual' | 'notification' | 'import'
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get detectedId =>
      text().nullable().references(DetectedTransactions, #id)();
}

class WalletAllocations extends Table with SyncColumns {
  TextColumn get sourceWalletId => text().references(Wallets, #id)();
  TextColumn get targetWalletId => text().references(Wallets, #id)();
  TextColumn get label => text().nullable()();

  /// Isi salah satu: [percent] atau [fixedAmount].
  RealColumn get percent => real().nullable()();
  RealColumn get fixedAmount => real().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class Transfers extends Table with SyncColumns {
  TextColumn get fromWalletId => text().references(Wallets, #id)();
  TextColumn get toWalletId => text().references(Wallets, #id)();
  RealColumn get amount => real()();
  RealColumn get fee => real().withDefault(const Constant(0))();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get note => text().nullable()();
  TextColumn get allocationId =>
      text().nullable().references(WalletAllocations, #id)();
}

class NotificationSources extends Table with SyncColumns {
  TextColumn get packageName => text()();
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get parserKey => text()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
}

class BudgetLimits extends Table with SyncColumns {
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  RealColumn get monthlyLimit => real()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
}

class SavingJars extends Table with SyncColumns {
  TextColumn get title => text()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get icon => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

class SavingJarEntries extends Table with SyncColumns {
  TextColumn get jarId => text().references(SavingJars, #id)();
  TextColumn get walletId => text().nullable().references(Wallets, #id)();
  RealColumn get amount => real()();

  /// 'deposit' | 'withdraw'
  TextColumn get type => text()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  TextColumn get note => text().nullable()();
}

/// Pengaturan user (1 baris, id = 'me'). Tidak memakai [SyncColumns]
/// karena di Supabase kuncinya adalah user_id.
class UserSettingsTable extends Table {
  @override
  String get tableName => 'user_settings';

  TextColumn get id => text().withDefault(const Constant('me'))();
  TextColumn get defaultExpenseWalletId =>
      text().nullable().references(Wallets, #id)();
  TextColumn get defaultIncomeWalletId =>
      text().nullable().references(Wallets, #id)();
  TextColumn get currency => text().withDefault(const Constant('IDR'))();
  BoolColumn get notificationCaptureEnabled =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('dirty'))();

  @override
  Set<Column> get primaryKey => {id};
}
