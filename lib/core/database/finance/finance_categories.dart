part of '../finance_repository.dart';

/// Kategori: seed bawaan, daftar, tambah, ubah, hapus.
extension FinanceCategories on FinanceRepository {
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
      b.insertAll(_db.categories, [
        for (final d in _defaults)
          CategoriesCompanion.insert(
            id: FinanceRepository._uuid.v5(
              Namespace.url.value,
              'moneta-default-category:$userId:${d.$2}:${d.$1}',
            ),
            name: d.$1,
            type: d.$2,
            icon: Value(d.$3),
          ),
      ], mode: InsertMode.insertOrIgnore);
    });
  }

  Stream<List<CategoryView>> watchCategories([String? type]) {
    final q = _db.select(_db.categories)..where((c) => c.deletedAt.isNull());
    if (type != null) q.where((c) => c.type.equals(type));
    q.orderBy([(c) => OrderingTerm(expression: c.createdAt)]);
    return q.watch().map(
      (rows) => [
        for (final c in rows) CategoryView(c.id, c.name, c.type, c.icon),
      ],
    );
  }

  Future<CategoryView> addCategory({
    required String name,
    required String type,
    String? icon,
    String? color,
  }) async {
    final id = FinanceRepository._uuid.v4();
    await _db
        .into(_db.categories)
        .insert(
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
    final now = FinanceRepository._s(DateTime.now());
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
}
