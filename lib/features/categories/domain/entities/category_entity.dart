import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_entity.freezed.dart';

/// Jenis kategori.
enum CategoryType {
  expense('expense'),
  income('income');

  const CategoryType(this.value);

  /// Nilai yang disimpan di database / dikirim ke server.
  final String value;

  static CategoryType fromValue(String value) =>
      value == 'income' ? CategoryType.income : CategoryType.expense;
}

const _defaultExpenseCategories = {
  'makanan',
  'transport',
  'belanja',
  'tagihan',
  'hiburan',
  'kesehatan',
  'lainnya',
};

const _defaultIncomeCategories = {
  'gaji',
  'bonus',
  'investasi',
  'penjualan',
  'lainnya',
};

/// Domain entity kategori transaksi.
@freezed
abstract class CategoryEntity with _$CategoryEntity {
  const CategoryEntity._();

  const factory CategoryEntity({
    required String id,
    required String name,
    required CategoryType type,
    String? icon,
  }) = _CategoryEntity;

  /// Kategori bawaan aplikasi (tidak boleh dihapus user).
  bool get isDefault {
    final lower = name.trim().toLowerCase();
    return type == CategoryType.income
        ? _defaultIncomeCategories.contains(lower)
        : _defaultExpenseCategories.contains(lower);
  }
}
