import 'package:equatable/equatable.dart';
import 'user_entity.dart';

enum AuthEventType {
  signedIn,
  signedOut,
  passwordRecovery,
  tokenRefreshed,
  userUpdated,
  initialSession,
}

/// Domain entity representing a reactive auth event and user session
class AuthStateEntity extends Equatable {
  final UserEntity? user;
  final AuthEventType event;

  const AuthStateEntity({
    required this.user,
    required this.event,
  });

  @override
  List<Object?> get props => [user, event];
}
