import '../../../../core/network/error/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../../domain/entities/auth_signup_result.dart';
import '../../domain/entities/auth_state_entity.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Reactive stream of user authentication status changes
  Stream<AuthStateEntity> get authStateChanges;

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email, password, and full name
  Future<AuthSignUpResult> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sign in with Google OAuth flow
  Future<UserModel> signInWithGoogle();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Update password for currently authenticated or recovery session
  Future<void> updatePassword(String newPassword);

  /// Sign out current session
  Future<void> signOut();

  /// Get current session user
  UserModel? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final sb.SupabaseClient supabase;

  AuthRemoteDataSourceImpl({required this.supabase});

  @override
  Stream<AuthStateEntity> get authStateChanges {
    return supabase.auth.onAuthStateChange.map((data) {
      final user = data.session?.user ?? supabase.auth.currentUser;
      final userModel = user != null ? UserModel.fromSupabaseUser(user) : null;

      AuthEventType eventType;
      switch (data.event) {
        case sb.AuthChangeEvent.passwordRecovery:
          eventType = AuthEventType.passwordRecovery;
          break;
        case sb.AuthChangeEvent.signedIn:
          eventType = AuthEventType.signedIn;
          break;
        case sb.AuthChangeEvent.signedOut:
          eventType = AuthEventType.signedOut;
          break;
        case sb.AuthChangeEvent.tokenRefreshed:
          eventType = AuthEventType.tokenRefreshed;
          break;
        case sb.AuthChangeEvent.userUpdated:
          eventType = AuthEventType.userUpdated;
          break;
        default:
          eventType = userModel != null
              ? AuthEventType.signedIn
              : AuthEventType.signedOut;
          break;
      }

      return AuthStateEntity(
        user: userModel?.toEntity(),
        event: eventType,
      );
    }).handleError((error) {
      // Gracefully handle OAuth cancellation or access_denied deep link errors
      return const AuthStateEntity(
        user: null,
        event: AuthEventType.signedOut,
      );
    });
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException(
          message: 'Gagal login. Data pengguna tidak ditemukan.',
        );
      }

      return UserModel.fromSupabaseUser(user);
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Terjadi kesalahan saat masuk: $e');
    }
  }

  @override
  Future<AuthSignUpResult> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
        emailRedirectTo: 'io.supabase.moneta://login-callback/',
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException(
          message: 'Pendaftaran gagal. Silakan coba lagi.',
        );
      }

      final userModel = UserModel.fromSupabaseUser(user);
      final needsVerification = response.session == null;

      return AuthSignUpResult(
        user: userModel.toEntity(),
        needsEmailVerification: needsVerification,
      );
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Terjadi kesalahan saat mendaftar: $e');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final isSuccess = await supabase.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        redirectTo: 'io.supabase.moneta://login-callback/',
      );

      if (!isSuccess) {
        throw const AuthException(
          message: 'Google Sign-In dibatalkan atau gagal dibuka.',
        );
      }

      final user = supabase.auth.currentUser;
      if (user != null) {
        return UserModel.fromSupabaseUser(user);
      }

      return UserModel(id: '', email: '', fullName: 'Google User');
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Google Sign-In gagal: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.moneta://reset-password/',
      );
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(
        message: 'Gagal mengirim email pemulihan password: $e',
      );
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        sb.UserAttributes(password: newPassword),
      );
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Gagal memperbarui password: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } on sb.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: 'Gagal keluar akun: $e');
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      return UserModel.fromSupabaseUser(user);
    }
    return null;
  }
}


