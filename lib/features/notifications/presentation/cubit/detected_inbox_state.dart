import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/detected_transaction_entity.dart';

part 'detected_inbox_state.freezed.dart';

enum DetectedInboxStatus { initial, loading, success, failure }

@freezed
abstract class DetectedInboxState with _$DetectedInboxState {
  const factory DetectedInboxState({
    @Default(DetectedInboxStatus.initial) DetectedInboxStatus status,
    @Default(<DetectedTransactionEntity>[]) List<DetectedTransactionEntity> items,
    String? errorMessage,
  }) = _DetectedInboxState;
}
