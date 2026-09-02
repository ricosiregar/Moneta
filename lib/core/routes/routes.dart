import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/analytics_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/main_shell.dart';
import '../../features/home/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/reports_page.dart';
import '../../features/home/presentation/pages/transactions_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeTabNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'homeTab');
final GlobalKey<NavigatorState> _analyticsTabNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'analyticsTab');
final GlobalKey<NavigatorState> _transactionsTabNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'transactionsTab');
final GlobalKey<NavigatorState> _reportsTabNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'reportsTab');
final GlobalKey<NavigatorState> _profileTabNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profileTab');

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
        final isAuthRoute = location == '/login' ||
            location == '/register' ||
            location == '/forgot-password';
        final isCallback = location.contains('login-callback') ||
            uriHost == 'login-callback' ||
            uriString.contains('login-callback');
        final isResetPassword = location == '/reset-password' ||
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
          body: Center(
            child: Text('Halaman tidak ditemukan: ${state.uri}'),
          ),
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

        // Nested Dashboard Routes with Persistent Stateful Bottom Navigation
        StatefulShellRoute.indexedStack(
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state, navigationShell) {
            return MainShell(navigationShell: navigationShell);
          },
          branches: [
            // Branch 0: Home / Overview
            StatefulShellBranch(
              navigatorKey: _homeTabNavigatorKey,
              routes: [
                GoRoute(
                  path: '/dashboard',
                  name: 'dashboard',
                  builder: (context, state) => const DashboardScreen(),
                ),
              ],
            ),

            // Branch 1: Analytics / Chart
            StatefulShellBranch(
              navigatorKey: _analyticsTabNavigatorKey,
              routes: [
                GoRoute(
                  path: '/analytics',
                  name: 'analytics',
                  builder: (context, state) => const AnalyticsScreen(),
                ),
              ],
            ),

            // Branch 2: Transactions
            StatefulShellBranch(
              navigatorKey: _transactionsTabNavigatorKey,
              routes: [
                GoRoute(
                  path: '/transactions',
                  name: 'transactions',
                  builder: (context, state) => const TransactionsScreen(),
                ),
              ],
            ),

            // Branch 3: Reports / Budgets
            StatefulShellBranch(
              navigatorKey: _reportsTabNavigatorKey,
              routes: [
                GoRoute(
                  path: '/reports',
                  name: 'reports',
                  builder: (context, state) => const ReportsScreen(),
                ),
              ],
            ),

            // Branch 4: Profile & Settings
            StatefulShellBranch(
              navigatorKey: _profileTabNavigatorKey,
              routes: [
                GoRoute(
                  path: '/profile',
                  name: 'profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
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
