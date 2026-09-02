import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
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
      ),
    );
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
