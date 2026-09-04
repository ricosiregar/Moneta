import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/main/cubit/bottom_nav_cubit.dart';
import '../../features/main/main_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final location = state.matchedLocation;
        final uriString = state.uri.toString();
        final uriHost = state.uri.host;

        final isSplash = location == '/splash';
        final isAuthRoute =
            location == '/login' ||
            location == '/register' ||
            location == '/forgot-password';
        final isCallback =
            location.contains('login-callback') ||
            uriHost == 'login-callback' ||
            uriString.contains('login-callback');
        final isResetPassword =
            location == '/reset-password' ||
            location.contains('reset-password') ||
            uriHost == 'reset-password' ||
            uriString.contains('reset-password') ||
            authState.status == AuthStatus.passwordRecovery;

        // 1. Password Recovery State (Deep link or recovery event) -> Always navigate to /reset-password
        if (isResetPassword) {
          return location == '/reset-password' ? null : '/reset-password';
        }

        // 2. Initial State (Checking Session on startup)
        if (authState.status == AuthStatus.initial) {
          return (isSplash || isCallback) ? null : '/splash';
        }

        // 3. Authenticated State (Logged in) -> Redirect auth & splash routes to dashboard
        if (authState.status == AuthStatus.authenticated) {
          return (isAuthRoute || isSplash || isCallback) ? '/dashboard' : null;
        }

        // 4. Unauthenticated State (Not logged in or awaiting verification)
        if (authState.status == AuthStatus.unauthenticated ||
            authState.status == AuthStatus.failure ||
            authState.status == AuthStatus.registeredNeedsVerification ||
            authState.status == AuthStatus.passwordResetEmailSent ||
            authState.status == AuthStatus.passwordUpdated) {
          if (isCallback) {
            // While Supabase is still parsing callback token
            return null;
          }
          return isAuthRoute ? null : '/login';
        }

        return null;
      },
      errorBuilder: (context, state) {
        if (state.uri.host == 'reset-password' ||
            state.uri.toString().contains('reset-password')) {
          return const ResetPasswordPage();
        }
        if (state.uri.host == 'login-callback' ||
            state.uri.toString().contains('login-callback')) {
          return const SplashPage();
        }
        return Scaffold(
          body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
        );
      },
      routes: [
        // Splash Route
        GoRoute(
          path: '/splash',
          name: 'splash',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SplashPage(),
        ),

        // Auth Routes
        GoRoute(
          path: '/login',
          name: 'login',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '/reset-password',
          name: 'reset-password',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ResetPasswordPage(),
        ),
        GoRoute(
          path: '/login-callback',
          name: 'login-callback',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SplashPage(),
        ),

        // Dashboard Route — menggunakan IndexedStack + BottomNavCubit
        // (pattern dari Metland-Card: navigasi tab tidak diikat ke URL,
        // tapi dikelola oleh BottomNavCubit dengan history stack).
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => BlocProvider(
            create: (_) => BottomNavCubit(),
            child: const MainPage(),
          ),
        ),
      ],
    );
  }
}

/// Converts a Stream into a Listenable for GoRouter refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
