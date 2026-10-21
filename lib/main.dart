import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/injection.dart';
import 'core/database/finance_repository.dart';
import 'core/network/interceptors/supabase_logging_interceptor.dart';
import 'core/routes/routes.dart';
import 'features/notifications/notification_capture_service.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  try {
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final publishableKey =
        dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
        dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl != null &&
        publishableKey != null &&
        publishableKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: publishableKey,
        httpClient: SupabaseLoggingClient(),
      );
    }
  } catch (e) {
    debugPrint("Warning: Failed to load .env or initialize Supabase: $e");
  }

  // Initialize Dependency Injection
  await configureDependencies();

  await LiquidGlassWidgets.initialize();

  await getIt<FinanceRepository>().seedDefaultCategories();

  // Mulai deteksi notifikasi bank (bila diaktifkan & izin ada). Tidak
  // memblokir startup.
  getIt<NotificationCaptureService>().start();

  runApp(LiquidGlassWidgets.wrap(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthBloc _authBloc;
  late final dynamic _router;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    _router = AppRouter.createRouter(_authBloc);
  }

  @override
  void dispose() {
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
