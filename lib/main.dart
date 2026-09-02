import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/injection.dart';
import 'core/network/interceptors/supabase_logging_interceptor.dart';
import 'core/routes/routes.dart';
import 'core/theme/app_colors.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['SUPABASE_PUBLISHABLE_KEY'];

    if (supabaseUrl != null && anonKey != null && anonKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: anonKey,
        httpClient: SupabaseLoggingClient(),
      );
    }
  } catch (e) {
    debugPrint("Warning: Failed to load .env or initialize Supabase: $e");
  }


  // Initialize Dependency Injection
  await configureDependencies();

  runApp(const MyApp());
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
    _authBloc.add(const AuthSubscriptionRequested());
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
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: AppColors.bgOffWhite,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryYellow,
            primary: AppColors.accentExpense,
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}


