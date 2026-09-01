import 'package:equatable/equatable.dart';
import 'user_entity.dart';

/// Domain entity representing the result of an email sign up operation
class AuthSignUpResult extends Equatable {
  final UserEntity user;
  final bool needsEmailVerification;

  const AuthSignUpResult({
    required this.user,
    required this.needsEmailVerification,
  });

  @override
  List<Object?> get props => [user, needsEmailVerification];
}
