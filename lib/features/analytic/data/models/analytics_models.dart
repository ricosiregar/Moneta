import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/analytics_entities.dart';

part 'analytics_models.freezed.dart';

@freezed
abstract class PeriodSummaryModel with _$PeriodSummaryModel {
  const PeriodSummaryModel._();

  const factory PeriodSummaryModel({
    required double income,
    required double expense,
    required int count,
  }) = _PeriodSummaryModel;

  PeriodSummaryEntity toEntity() =>
      PeriodSummaryEntity(income: income, expense: expense, count: count);
}

@freezed
abstract class CategoryTotalModel with _$CategoryTotalModel {
  const CategoryTotalModel._();

  const factory CategoryTotalModel({
    required String name,
    required double total,
    String? categoryId,
    String? icon,
    required int count,
  }) = _CategoryTotalModel;

  CategoryTotalEntity toEntity() => CategoryTotalEntity(
        name: name,
        total: total,
        categoryId: categoryId,
        icon: icon,
        count: count,
      );
}

@freezed
abstract class DailyTotalModel with _$DailyTotalModel {
  const DailyTotalModel._();

  const factory DailyTotalModel({
    required DateTime date,
    required double income,
    required double expense,
  }) = _DailyTotalModel;

  DailyTotalEntity toEntity() =>
      DailyTotalEntity(date: date, income: income, expense: expense);
}
