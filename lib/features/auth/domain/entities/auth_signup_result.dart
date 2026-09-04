import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_entity.dart';

part 'auth_signup_result.freezed.dart';

/// Result entity returned when registering a new account
@freezed
abstract class AuthSignUpResult with _$AuthSignUpResult {
  const factory AuthSignUpResult({
    required UserEntity? user,
    required bool needsEmailVerification,
  }) = _AuthSignUpResult;
}
