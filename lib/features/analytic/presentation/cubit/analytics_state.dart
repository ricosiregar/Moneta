import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../wallets/domain/entities/wallet_entity.dart';
import '../../domain/entities/analytics_entities.dart';

part 'analytics_state.freezed.dart';

enum AnalyticsStatus { initial, loading, success, failure }

@freezed
abstract class AnalyticsState with _$AnalyticsState {
  const factory AnalyticsState({
    @Default(AnalyticsStatus.initial) AnalyticsStatus status,
    @Default(<WalletEntity>[]) List<WalletEntity> wallets,
    @Default(PeriodSummaryEntity()) PeriodSummaryEntity summary,
    @Default(<CategoryTotalEntity>[]) List<CategoryTotalEntity> categories,
    @Default(<DailyTotalEntity>[]) List<DailyTotalEntity> daily,
    @Default(<DailyTotalEntity>[]) List<DailyTotalEntity> trend,
    String? errorMessage,
  }) = _AnalyticsState;
}
