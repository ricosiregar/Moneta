import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/jar_entity.dart';

part 'jar_model.freezed.dart';

@freezed
abstract class JarModel with _$JarModel {
  const JarModel._();

  const factory JarModel({
    required String id,
    required String title,
    required double target,
    required double saved,
    String? icon,
    DateTime? targetDate,
  }) = _JarModel;

  JarEntity toEntity() => JarEntity(
        id: id,
        title: title,
        target: target,
        saved: saved,
        icon: icon,
        targetDate: targetDate,
      );
}
