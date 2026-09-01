import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final location = state.matchedLocation;

        final isSplash = location == '/splash';
        final isAuthRoute = location == '/login' || location == '/register';
        final isCallback = location.contains('login-callback');

        // 1. Initial State (Checking Session on startup)
        if (authState.status == AuthStatus.initial) {
          return (isSplash || isCallback) ? null : '/splash';
        }

        // 2. Authenticated State (Logged in) -> Redirect to dashboard
        if (authState.status == AuthStatus.authenticated) {
          return (isAuthRoute || isSplash || isCallback) ? '/dashboard' : null;
        }

        // 3. Unauthenticated State (Not logged in or awaiting verification)
        if (authState.status == AuthStatus.unauthenticated ||
            authState.status == AuthStatus.failure ||
            authState.status == AuthStatus.registeredNeedsVerification) {
          if (isCallback) {
            // While Supabase is still parsing callback token
            return null;
          }
          return isAuthRoute ? null : '/login';
        }

        return null;
      },
      errorBuilder: (context, state) {
        if (state.uri.toString().contains('login-callback')) {
          return const SplashPage();
        }
        return Scaffold(
          body: Center(
            child: Text('Halaman tidak ditemukan: ${state.uri}'),
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/login-callback',
          name: 'login-callback',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
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
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
