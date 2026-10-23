import 'package:freezed_annotation/freezed_annotation.dart';

part 'jar_entity.freezed.dart';

/// Celengan (target tabungan).
@freezed
abstract class JarEntity with _$JarEntity {
  const factory JarEntity({
    required String id,
    required String title,
    required double target,
    required double saved,
    String? icon,
    DateTime? targetDate,
  }) = _JarEntity;
}
