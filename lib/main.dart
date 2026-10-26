import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/di/injection.dart';
import 'core/database/finance_repository.dart';
import 'core/network/interceptors/supabase_logging_interceptor.dart';
import 'core/routes/routes.dart';
import 'features/notifications/data/services/notification_capture_service.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'core/sync/sync_service.dart';

bool _supabaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Error async yang tak tertangkap dicatat, tidak menjatuhkan aplikasi.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };
  await _bootstrapAndRun();
}

/// Jalankan inisialisasi; bila gagal tampilkan layar error dengan opsi coba
/// lagi (alih-alih layar putih akibat crash saat DI membuat AuthBloc).
Future<void> _bootstrapAndRun() async {
  try {
    await _bootstrap();
  } catch (e, st) {
    debugPrint('Startup gagal: $e\n$st');
    runApp(_StartupErrorApp(error: e, onRetry: _bootstrapAndRun));
    return;
  }
  runApp(LiquidGlassWidgets.wrap(child: const MyApp()));
}

Future<void> _bootstrap() async {
  await initializeDateFormatting('id_ID');

  // Supabase hanya boleh diinisialisasi sekali (aman untuk retry).
  if (!_supabaseReady) {
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final publishableKey =
        dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
        dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null ||
        supabaseUrl.isEmpty ||
        publishableKey == null ||
        publishableKey.isEmpty) {
      throw StateError('Konfigurasi server (.env) belum lengkap.');
    }
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: publishableKey,
      httpClient: SupabaseLoggingClient(),
    );
    _supabaseReady = true;
  }

  // Initialize Dependency Injection
  await configureDependencies();

  try {
    await LiquidGlassWidgets.initialize();
  } catch (e) {
    // Hanya memengaruhi efek visual; jangan blokir aplikasi.
    debugPrint('LiquidGlassWidgets gagal diinisialisasi: $e');
  }

  // Seed kategori bawaan dipindah ke _MyAppState._onAuthState (setelah login)
  // karena butuh userId agar ID kategori konsisten antar perangkat.

  // Mulai deteksi notifikasi bank (bila diaktifkan & izin ada). Tidak
  // memblokir startup, dan kegagalannya tidak boleh menjadi unhandled error.
  unawaited(
    getIt<NotificationCaptureService>().start().catchError((Object e) {
      debugPrint('Gagal memulai deteksi notifikasi: $e');
    }),
  );
}

/// Layar darurat bila inisialisasi gagal. Sengaja tidak bergantung pada DI,
/// tema kustom, maupun Supabase.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 56),
                const SizedBox(height: 16),
                const Text(
                  'Aplikasi gagal dimulai',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  error is StateError
                      ? (error as StateError).message
                      : 'Terjadi kendala saat menyiapkan aplikasi. Silakan coba lagi.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('startup_retry_button'),
                  onPressed: onRetry,
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;
  StreamSubscription<AuthState>? _authSub;
  String? _boundUserId;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    _router = AppRouter.createRouter(_authBloc);
    _authSub = _authBloc.stream.listen(_onAuthState);
    _onAuthState(_authBloc.state);
  }

  /// Saat user login: pastikan data lokal milik user ini (hapus bila milik
  /// akun lain), tarik data dari cloud (sync) terlebih dahulu agar data lama
  /// otomatis kembali saat install ulang APK, lalu seed kategori bawaan bila
  /// tabel kategori masih kosong (akun baru / sedang offline).
  Future<void> _onAuthState(AuthState s) async {
    final id = s.user?.id;
    if (s.status != AuthStatus.authenticated || id == null || id.isEmpty) {
      if (s.status == AuthStatus.unauthenticated) {
        _boundUserId = null;
      }
      return;
    }
    if (id == _boundUserId) return;
    _boundUserId = id;
    try {
      final syncService = getIt<SyncService>();
      final financeRepo = getIt<FinanceRepository>();
      await syncService.bindUser(id);
      try {
        await syncService.sync();
      } catch (e) {
        debugPrint('Auto-sync saat login tertunda: $e');
      }
      await financeRepo.seedDefaultCategories(userId: id);
    } catch (e) {
      _boundUserId = null; // coba lagi pada perubahan state berikutnya
      debugPrint('Gagal menyiapkan data lokal: $e');
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'Moneta',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'PlusJakartaSans',
          scaffoldBackgroundColor: AppColors.canvas,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.accentBlue,
            primary: AppColors.primarySlate,
            surface: AppColors.surface,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.canvas,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.inkPrimary),
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}
