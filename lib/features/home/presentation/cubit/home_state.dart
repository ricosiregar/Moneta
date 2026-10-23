import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../analytic/domain/entities/analytics_entities.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../wallets/domain/entities/wallet_entity.dart';

part 'home_state.freezed.dart';

enum HomeStatus { initial, loading, success, failure }

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(HomeStatus.initial) HomeStatus status,
    @Default(<WalletEntity>[]) List<WalletEntity> wallets,
    @Default(<CategoryEntity>[]) List<CategoryEntity> expenseCategories,

    /// Ringkasan [hari ini, minggu ini, bulan ini].
    @Default(<PeriodSummaryEntity>[
      PeriodSummaryEntity(),
      PeriodSummaryEntity(),
      PeriodSummaryEntity(),
    ])
    List<PeriodSummaryEntity> summaries,
    String? errorMessage,
  }) = _HomeState;
}
