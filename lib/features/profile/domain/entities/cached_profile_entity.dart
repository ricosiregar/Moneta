import 'package:freezed_annotation/freezed_annotation.dart';

part 'cached_profile_entity.freezed.dart';

/// Nama & email terakhir yang tersimpan di perangkat (tampil saat offline).
@freezed
abstract class CachedProfileEntity with _$CachedProfileEntity {
  const factory CachedProfileEntity({
    @Default('') String name,
    @Default('') String email,
  }) = _CachedProfileEntity;
}
