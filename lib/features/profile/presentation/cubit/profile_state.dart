import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default('') String cachedName,
    @Default('') String cachedEmail,

    /// True saat ekspor/impor/hapus sedang berjalan.
    @Default(false) bool busy,
  }) = _ProfileState;
}
