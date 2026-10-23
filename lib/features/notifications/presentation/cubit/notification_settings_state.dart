import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/notification_source_entity.dart';

part 'notification_settings_state.freezed.dart';

@freezed
abstract class NotificationSettingsState with _$NotificationSettingsState {
  const factory NotificationSettingsState({
    @Default(false) bool captureEnabled,
    @Default(<NotificationSourceEntity>[]) List<NotificationSourceEntity> sources,
    String? errorMessage,
  }) = _NotificationSettingsState;
}
