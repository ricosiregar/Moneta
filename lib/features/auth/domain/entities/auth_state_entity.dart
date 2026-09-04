import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_entity.dart';

part 'auth_state_entity.freezed.dart';

enum AuthEventType {
  signedIn,
  signedOut,
  passwordRecovery,
  tokenRefreshed,
  userUpdated,
  initialSession,
}

/// Domain entity representing a reactive auth event and user session
@freezed
abstract class AuthStateEntity with _$AuthStateEntity {
  const factory AuthStateEntity({
    required UserEntity? user,
    required AuthEventType event,
  }) = _AuthStateEntity;
}
