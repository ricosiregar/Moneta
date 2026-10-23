import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_entities.freezed.dart';

/// Ringkasan pemasukan/pengeluaran pada satu periode.
@freezed
abstract class PeriodSummaryEntity with _$PeriodSummaryEntity {
  const factory PeriodSummaryEntity({
    @Default(0) double income,
    @Default(0) double expense,
    @Default(0) int count,
  }) = _PeriodSummaryEntity;
}

/// Total pengeluaran satu kategori.
@freezed
abstract class CategoryTotalEntity with _$CategoryTotalEntity {
  const factory CategoryTotalEntity({
    required String name,
    required double total,
    String? categoryId,
    String? icon,
    @Default(0) int count,
  }) = _CategoryTotalEntity;
}

/// Total pemasukan/pengeluaran satu hari.
@freezed
abstract class DailyTotalEntity with _$DailyTotalEntity {
  const factory DailyTotalEntity({
    required DateTime date,
    required double income,
    required double expense,
  }) = _DailyTotalEntity;
}
