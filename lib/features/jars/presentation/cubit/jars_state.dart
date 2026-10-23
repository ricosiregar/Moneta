import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/jar_entity.dart';

part 'jars_state.freezed.dart';

enum JarsStatus { initial, loading, success, failure }

@freezed
abstract class JarsState with _$JarsState {
  const factory JarsState({
    @Default(JarsStatus.initial) JarsStatus status,
    @Default(<JarEntity>[]) List<JarEntity> jars,
    String? errorMessage,
  }) = _JarsState;
}
