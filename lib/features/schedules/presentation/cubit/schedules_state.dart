import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auto_schedule_entity.dart';

part 'schedules_state.freezed.dart';

enum SchedulesStatus { initial, loading, success, failure }

@freezed
abstract class SchedulesState with _$SchedulesState {
  const factory SchedulesState({
    @Default(SchedulesStatus.initial) SchedulesStatus status,
    @Default(<AutoScheduleEntity>[]) List<AutoScheduleEntity> schedules,
    String? errorMessage,
  }) = _SchedulesState;
}
