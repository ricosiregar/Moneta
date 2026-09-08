import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/entities/auth_state_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthStateStreamUseCase getAuthStateStream;
  final SignInWithEmailUseCase signInWithEmail;
  final SignUpWithEmailUseCase signUpWithEmail;
  final SignInWithGoogleUseCase signInWithGoogle;
  final SendPasswordResetEmailUseCase sendPasswordResetEmail;
  final UpdatePasswordUseCase updatePassword;
  final SignOutUseCase signOut;
  final GetCurrentUserUseCase getCurrentUser;
  final AppLocalStorage localStorage;

  StreamSubscription? _authStateSubscription;

  AuthBloc({
    required this.getAuthStateStream,
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signInWithGoogle,
    required this.sendPasswordResetEmail,
    required this.updatePassword,
    required this.signOut,
    required this.getCurrentUser,
    required this.localStorage,
  }) : super(const AuthState()) {
    on<AuthSubscriptionRequested>(_onAuthSubscriptionRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<GoogleSignInSubmitted>(_onGoogleSignInSubmitted);
    on<ForgotPasswordSubmitted>(_onForgotPasswordSubmitted);
    on<UpdatePasswordSubmitted>(_onUpdatePasswordSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthSubscriptionRequested(
    AuthSubscriptionRequested event,
    Emitter<AuthState> emit,
  ) async {
    // 1. Initial active session check
    final initialUserResult = await getCurrentUser(const NoParams());

    // Ekstrak user di luar fold agar bisa await secara sequential
    UserEntity? initialUser;
    initialUserResult.fold(
      (_) => initialUser = null,
      (user) => initialUser = user,
    );

    if (initialUser != null) {
      // Simpan nama ke SharedPreferences agar tersedia offline
      final name = initialUser!.fullName;
      if (name != null && name.isNotEmpty) {
        await localStorage.saveUserName(name);
      }
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: initialUser,
          errorMessage: null,
        ),
      );
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    }

    // 2. Cancel previous subscription if any
    await _authStateSubscription?.cancel();

    // 3. Listen to live reactive stream
    _authStateSubscription = getAuthStateStream().listen(
      (authStateEntity) => add(AuthUserChanged(authStateEntity)),
    );
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.authStateEntity.event == AuthEventType.passwordRecovery) {
      emit(
        state.copyWith(
          status: AuthStatus.passwordRecovery,
          user: event.authStateEntity.user,
          errorMessage: null,
        ),
      );
    } else if (event.authStateEntity.user != null) {
      final user = event.authStateEntity.user!;
      // Simpan nama ke SharedPreferences agar tersedia offline
      final name = user.fullName;
      if (name != null && name.isNotEmpty) {
        localStorage.saveUserName(name);
      }
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          errorMessage: null,
        ),
      );
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await signInWithEmail(
      SignInWithEmailParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) async {
        // Simpan nama user ke SharedPreferences
        if (user.fullName != null && user.fullName!.isNotEmpty) {
          await localStorage.saveUserName(user.fullName!);
        }
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            errorMessage: null,
          ),
        );
      },
    );
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await signUpWithEmail(
      SignUpWithEmailParams(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      ),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (signUpResult) async {
        // Simpan nama user ke SharedPreferences
        final fullName = signUpResult.user?.fullName;
        if (fullName != null && fullName.isNotEmpty) {
          await localStorage.saveUserName(fullName);
        }
        if (signUpResult.needsEmailVerification) {
          emit(
            state.copyWith(
              status: AuthStatus.registeredNeedsVerification,
              user: signUpResult.user,
              unverifiedEmail: event.email,
              errorMessage: null,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: signUpResult.user,
              errorMessage: null,
            ),
          );
        }
      },
    );
  }

  Future<void> _onGoogleSignInSubmitted(
    GoogleSignInSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    final result = await signInWithGoogle(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) {
        if (user.id.isNotEmpty) {
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              errorMessage: null,
            ),
          );
        } else {
          // OAuth browser was opened. Reset loading status so if user cancels or returns, UI is not stuck.
          emit(
            state.copyWith(
              status: AuthStatus.unauthenticated,
              errorMessage: null,
            ),
          );
        }
      },
    );
  }

  Future<void> _onForgotPasswordSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    ));

    final result = await sendPasswordResetEmail(
      SendPasswordResetEmailParams(email: event.email),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: AuthStatus.passwordResetEmailSent,
          successMessage:
              'Tautan reset password telah dikirim ke ${event.email}',
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onUpdatePasswordSubmitted(
    UpdatePasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      successMessage: null,
    ));

    final result = await updatePassword(
      UpdatePasswordParams(newPassword: event.newPassword),
    );

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: AuthStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) async {
        await signOut(const NoParams());
        emit(
          state.copyWith(
            status: AuthStatus.passwordUpdated,
            successMessage:
                'Password berhasil diperbarui. Silakan login kembali.',
            user: null,
            errorMessage: null,
          ),
        );
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await signOut(const NoParams());
    // Hapus nama user dari SharedPreferences saat logout
    await localStorage.clearUserName();
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      ),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
