import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../backup/backup_service.dart';
import '../database/app_database.dart';
import '../database/detected_repository.dart';
import '../database/finance_repository.dart';
import '../../features/notifications/notification_capture_service.dart';
import '../database/wallet_repository.dart';
import '../sync/sync_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../storage/local_storage.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true, asExtension: true)
Future<void> configureDependencies() async {
  // 1. Third Party Clients & Storage
  if (!getIt.isRegistered<SupabaseClient>()) {
    getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  }
  if (!getIt.isRegistered<SharedPreferences>()) {
    final prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);
  }
  if (!getIt.isRegistered<AppLocalStorage>()) {
    getIt.registerLazySingleton<AppLocalStorage>(
      () => AppLocalStorageImpl(sharedPreferences: getIt<SharedPreferences>()),
    );
  }

  // 1b. Local database & sync
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  }
  if (!getIt.isRegistered<FinanceRepository>()) {
    getIt.registerLazySingleton<FinanceRepository>(
      () => FinanceRepository(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<BackupService>()) {
    getIt.registerLazySingleton<BackupService>(
      () => BackupService(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<DetectedRepository>()) {
    getIt.registerLazySingleton<DetectedRepository>(
      () => DetectedRepository(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<NotificationCaptureService>()) {
    getIt.registerLazySingleton<NotificationCaptureService>(
      () => NotificationCaptureService(getIt<DetectedRepository>()),
    );
  }
  if (!getIt.isRegistered<WalletRepository>()) {
    getIt.registerLazySingleton<WalletRepository>(
      () => WalletRepository(getIt<AppDatabase>()),
    );
  }
  if (!getIt.isRegistered<SyncService>()) {
    getIt.registerLazySingleton<SyncService>(
      () => SyncService(
        db: getIt<AppDatabase>(),
        supabase: getIt<SupabaseClient>(),
        prefs: getIt<SharedPreferences>(),
      ),
    );
  }

  // 2. Auth Data Layer
  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(supabase: getIt<SupabaseClient>()),
    );
  }
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
    );
  }

  // 3. Auth Domain UseCases
  if (!getIt.isRegistered<GetAuthStateStreamUseCase>()) {
    getIt.registerLazySingleton(
      () => GetAuthStateStreamUseCase(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<SignInWithEmailUseCase>()) {
    getIt.registerLazySingleton(
      () => SignInWithEmailUseCase(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<SignUpWithEmailUseCase>()) {
    getIt.registerLazySingleton(
      () => SignUpWithEmailUseCase(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<SignInWithGoogleUseCase>()) {
    getIt.registerLazySingleton(
      () => SignInWithGoogleUseCase(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<SignOutUseCase>()) {
    getIt.registerLazySingleton(() => SignOutUseCase(getIt<AuthRepository>()));
  }
  if (!getIt.isRegistered<GetCurrentUserUseCase>()) {
    getIt.registerLazySingleton(
      () => GetCurrentUserUseCase(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<SendPasswordResetEmailUseCase>()) {
    getIt.registerLazySingleton(
      () => SendPasswordResetEmailUseCase(getIt<AuthRepository>()),
    );
  }
  if (!getIt.isRegistered<UpdatePasswordUseCase>()) {
    getIt.registerLazySingleton(
      () => UpdatePasswordUseCase(getIt<AuthRepository>()),
    );
  }

  // 4. Auth Presentation BLoC
  if (!getIt.isRegistered<AuthBloc>()) {
    getIt.registerFactory<AuthBloc>(
      () => AuthBloc(
        getAuthStateStream: getIt<GetAuthStateStreamUseCase>(),
        signInWithEmail: getIt<SignInWithEmailUseCase>(),
        signUpWithEmail: getIt<SignUpWithEmailUseCase>(),
        signInWithGoogle: getIt<SignInWithGoogleUseCase>(),
        sendPasswordResetEmail: getIt<SendPasswordResetEmailUseCase>(),
        updatePassword: getIt<UpdatePasswordUseCase>(),
        signOut: getIt<SignOutUseCase>(),
        getCurrentUser: getIt<GetCurrentUserUseCase>(),
        localStorage: getIt<AppLocalStorage>(),
      ),
    );
  }

  // 5. Home Data Layer
  if (!getIt.isRegistered<HomeRemoteDataSource>()) {
    getIt.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(supabase: getIt<SupabaseClient>()),
    );
  }
  if (!getIt.isRegistered<HomeRepository>()) {
    getIt.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remoteDataSource: getIt<HomeRemoteDataSource>()),
    );
  }

  // 6. Home Presentation Cubit
  if (!getIt.isRegistered<HomeCubit>()) {
    getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt<HomeRepository>()));
  }
}

@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
