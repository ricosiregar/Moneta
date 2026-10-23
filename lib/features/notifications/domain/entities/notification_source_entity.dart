import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_source_entity.freezed.dart';

/// Aplikasi (bank / e-wallet) yang dipantau notifikasinya dan dompet tujuannya.
@freezed
abstract class NotificationSourceEntity with _$NotificationSourceEntity {
  const factory NotificationSourceEntity({
    required String id,
    required String packageName,
    required String walletId,
    required String parserKey,
    required bool isEnabled,
  }) = _NotificationSourceEntity;
}
