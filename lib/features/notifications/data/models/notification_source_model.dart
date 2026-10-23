import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/notification_source_entity.dart';

part 'notification_source_model.freezed.dart';

@freezed
abstract class NotificationSourceModel with _$NotificationSourceModel {
  const NotificationSourceModel._();

  const factory NotificationSourceModel({
    required String id,
    required String packageName,
    required String walletId,
    required String parserKey,
    required bool isEnabled,
  }) = _NotificationSourceModel;

  NotificationSourceEntity toEntity() => NotificationSourceEntity(
        id: id,
        packageName: packageName,
        walletId: walletId,
        parserKey: parserKey,
        isEnabled: isEnabled,
      );
}
