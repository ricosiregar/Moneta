import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../backup/backup_service.dart';
import '../database/app_database.dart';
import '../database/detected_repository.dart';
import '../database/finance_repository.dart';
import '../../features/notifications/data/services/notification_capture_service.dart';
import '../database/wallet_repository.dart';
import '../sync/sync_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/analytic/data/datasources/analytics_local_datasource.dart';
import '../../features/analytic/data/repositories/analytics_repository_impl.dart';
import '../../features/analytic/domain/repositories/analytics_repository.dart';
import '../../features/analytic/domain/usecases/analytics_usecases.dart';
import '../../features/analytic/presentation/cubit/analytics_cubit.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/profile/data/datasources/profile_local_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/profile_usecases.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/budgets/data/datasources/budgets_local_datasource.dart';
import '../../features/budgets/data/repositories/budgets_repository_impl.dart';
import '../../features/budgets/domain/repositories/budgets_repository.dart';
import '../../features/budgets/domain/usecases/budget_usecases.dart';
import '../../features/budgets/presentation/cubit/budgets_cubit.dart';
import '../../features/jars/data/datasources/jars_local_datasource.dart';
import '../../features/jars/data/repositories/jars_repository_impl.dart';
import '../../features/jars/domain/repositories/jars_repository.dart';
import '../../features/jars/domain/usecases/jar_usecases.dart';
import '../../features/jars/presentation/cubit/jars_cubit.dart';
import '../../features/schedules/data/datasources/schedules_local_datasource.dart';
import '../../features/schedules/data/repositories/schedules_repository_impl.dart';
import '../../features/schedules/domain/repositories/schedules_repository.dart';
import '../../features/schedules/domain/usecases/schedule_usecases.dart';
import '../../features/schedules/presentation/cubit/schedules_cubit.dart';
import '../../features/transactions/data/datasources/transactions_local_datasource.dart';
import '../../features/transactions/data/repositories/transactions_repository_impl.dart';
import '../../features/transactions/domain/repositories/transactions_repository.dart';
import '../../features/transactions/domain/usecases/transaction_usecases.dart';
import '../../features/transactions/presentation/cubit/transaction_form_cubit.dart';
import '../../features/transactions/presentation/cubit/transactions_cubit.dart';
import '../../features/wallets/data/datasources/wallets_local_datasource.dart';
import '../../features/wallets/data/repositories/wallets_repository_impl.dart';
import '../../features/wallets/domain/repositories/wallets_repository.dart';
import '../../features/wallets/domain/usecases/wallet_usecases.dart';
import '../../features/wallets/presentation/cubit/wallets_cubit.dart';
import '../../features/notifications/data/datasources/notification_local_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/notification_usecases.dart';
import '../../features/notifications/presentation/cubit/detected_inbox_cubit.dart';
import '../../features/notifications/presentation/cubit/notification_settings_cubit.dart';
import '../../features/categories/data/datasources/category_local_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/domain/usecases/category_usecases.dart';
import '../../features/categories/presentation/cubit/categories_cubit.dart';
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

  // 4b. Categories (data -> domain -> presentation)
  if (!getIt.isRegistered<CategoryLocalDataSource>()) {
    getIt.registerLazySingleton<CategoryLocalDataSource>(
      () => CategoryLocalDataSourceImpl(finance: getIt<FinanceRepository>()),
    );
  }
  if (!getIt.isRegistered<CategoryRepository>()) {
    getIt.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(
        localDataSource: getIt<CategoryLocalDataSource>(),
      ),
    );
  }
  if (!getIt.isRegistered<WatchCategoriesUseCase>()) {
    getIt.registerLazySingleton(
      () => WatchCategoriesUseCase(getIt<CategoryRepository>()),
    );
  }
  if (!getIt.isRegistered<AddCategoryUseCase>()) {
    getIt.registerLazySingleton(
      () => AddCategoryUseCase(getIt<CategoryRepository>()),
    );
  }
  if (!getIt.isRegistered<DeleteCategoryUseCase>()) {
    getIt.registerLazySingleton(
      () => DeleteCategoryUseCase(getIt<CategoryRepository>()),
    );
  }
  if (!getIt.isRegistered<CategoriesCubit>()) {
    getIt.registerFactory<CategoriesCubit>(
      () => CategoriesCubit(
        watchCategories: getIt<WatchCategoriesUseCase>(),
        addCategory: getIt<AddCategoryUseCase>(),
        deleteCategory: getIt<DeleteCategoryUseCase>(),
      ),
    );
  }

  // 4c. Notifications (data -> domain -> presentation)
  if (!getIt.isRegistered<NotificationLocalDataSource>()) {
    getIt.registerLazySingleton<NotificationLocalDataSource>(
      () => NotificationLocalDataSourceImpl(
        detected: getIt<DetectedRepository>(),
      ),
    );
  }
  if (!getIt.isRegistered<NotificationRepository>()) {
    getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        localDataSource: getIt<NotificationLocalDataSource>(),
      ),
    );
  }
  void useCase<T extends Object>(T Function(NotificationRepository) make) {
    if (!getIt.isRegistered<T>()) {
      getIt.registerLazySingleton<T>(() => make(getIt<NotificationRepository>()));
    }
  }

  useCase(WatchPendingDetectedUseCase.new);
  useCase(RecordDetectedUseCase.new);
  useCase(IgnoreDetectedUseCase.new);
  useCase(IgnoreAllDetectedUseCase.new);
  useCase(ChangeDetectedWalletUseCase.new);
  useCase(ChangeDetectedTypeUseCase.new);
  useCase(WatchSourcesUseCase.new);
  useCase(UpsertSourceUseCase.new);
  useCase(SetSourceEnabledUseCase.new);
  useCase(DeleteSourceUseCase.new);
  useCase(WatchCaptureEnabledUseCase.new);
  useCase(SetCaptureEnabledUseCase.new);

  if (!getIt.isRegistered<DetectedInboxCubit>()) {
    getIt.registerFactory<DetectedInboxCubit>(
      () => DetectedInboxCubit(
        watchPending: getIt<WatchPendingDetectedUseCase>(),
        record: getIt<RecordDetectedUseCase>(),
        ignore: getIt<IgnoreDetectedUseCase>(),
        ignoreAll: getIt<IgnoreAllDetectedUseCase>(),
        changeWallet: getIt<ChangeDetectedWalletUseCase>(),
        changeType: getIt<ChangeDetectedTypeUseCase>(),
      ),
    );
  }
  if (!getIt.isRegistered<NotificationSettingsCubit>()) {
    getIt.registerFactory<NotificationSettingsCubit>(
      () => NotificationSettingsCubit(
        watchSources: getIt<WatchSourcesUseCase>(),
        watchCaptureEnabled: getIt<WatchCaptureEnabledUseCase>(),
        setCaptureEnabled: getIt<SetCaptureEnabledUseCase>(),
        upsertSource: getIt<UpsertSourceUseCase>(),
        setSourceEnabled: getIt<SetSourceEnabledUseCase>(),
        deleteSource: getIt<DeleteSourceUseCase>(),
      ),
    );
  }

  // 4d. Wallets (data -> domain -> presentation)
  if (!getIt.isRegistered<WalletsLocalDataSource>()) {
    getIt.registerLazySingleton<WalletsLocalDataSource>(
      () => WalletsLocalDataSourceImpl(wallets: getIt<WalletRepository>()),
    );
  }
  if (!getIt.isRegistered<WalletsRepository>()) {
    getIt.registerLazySingleton<WalletsRepository>(
      () => WalletsRepositoryImpl(
        localDataSource: getIt<WalletsLocalDataSource>(),
      ),
    );
  }
  void walletUseCase<T extends Object>(T Function(WalletsRepository) make) {
    if (!getIt.isRegistered<T>()) {
      getIt.registerLazySingleton<T>(() => make(getIt<WalletsRepository>()));
    }
  }

  walletUseCase(WatchWalletsUseCase.new);
  walletUseCase(GetWalletsUseCase.new);
  walletUseCase(GetAllocationsUseCase.new);
  walletUseCase(SaveWalletUseCase.new);
  walletUseCase(DeleteWalletUseCase.new);
  walletUseCase(SaveAllocationsUseCase.new);
  walletUseCase(CreateTransferUseCase.new);

  if (!getIt.isRegistered<WalletsCubit>()) {
    getIt.registerFactory<WalletsCubit>(
      () => WalletsCubit(
        watchWallets: getIt<WatchWalletsUseCase>(),
        getAllocations: getIt<GetAllocationsUseCase>(),
        saveWallet: getIt<SaveWalletUseCase>(),
        deleteWallet: getIt<DeleteWalletUseCase>(),
        saveAllocations: getIt<SaveAllocationsUseCase>(),
        createTransfer: getIt<CreateTransferUseCase>(),
      ),
    );
  }

  // 4e. Transactions (data -> domain -> presentation)
  if (!getIt.isRegistered<TransactionsLocalDataSource>()) {
    getIt.registerLazySingleton<TransactionsLocalDataSource>(
      () => TransactionsLocalDataSourceImpl(finance: getIt<FinanceRepository>()),
    );
  }
  if (!getIt.isRegistered<TransactionsRepository>()) {
    getIt.registerLazySingleton<TransactionsRepository>(
      () => TransactionsRepositoryImpl(
        localDataSource: getIt<TransactionsLocalDataSource>(),
      ),
    );
  }
  void txUseCase<T extends Object>(T Function(TransactionsRepository) make) {
    if (!getIt.isRegistered<T>()) {
      getIt.registerLazySingleton<T>(() => make(getIt<TransactionsRepository>()));
    }
  }

  txUseCase(WatchFeedUseCase.new);
  txUseCase(AddTransactionUseCase.new);
  txUseCase(DeleteFeedItemUseCase.new);

  if (!getIt.isRegistered<TransactionsCubit>()) {
    getIt.registerFactory<TransactionsCubit>(
      () => TransactionsCubit(
        watchFeed: getIt<WatchFeedUseCase>(),
        watchWallets: getIt<WatchWalletsUseCase>(),
        watchCategories: getIt<WatchCategoriesUseCase>(),
        deleteItem: getIt<DeleteFeedItemUseCase>(),
      ),
    );
  }
  if (!getIt.isRegistered<TransactionFormCubit>()) {
    getIt.registerFactory<TransactionFormCubit>(
      () => TransactionFormCubit(
        watchWallets: getIt<WatchWalletsUseCase>(),
        watchCategories: getIt<WatchCategoriesUseCase>(),
        addTransaction: getIt<AddTransactionUseCase>(),
      ),
    );
  }

  // 4f. Budgets, Jars, Schedules (data -> domain -> presentation)
  void single<T extends Object>(T Function() make) {
    if (!getIt.isRegistered<T>()) getIt.registerLazySingleton<T>(make);
  }

  void factory<T extends Object>(T Function() make) {
    if (!getIt.isRegistered<T>()) getIt.registerFactory<T>(make);
  }

  final fin = getIt<FinanceRepository>();
  single<BudgetsLocalDataSource>(
      () => BudgetsLocalDataSourceImpl(finance: fin));
  single<BudgetsRepository>(() => BudgetsRepositoryImpl(
      localDataSource: getIt<BudgetsLocalDataSource>()));
  single(() => WatchBudgetsUseCase(getIt<BudgetsRepository>()));
  single(() => SaveBudgetUseCase(getIt<BudgetsRepository>()));
  single(() => DeleteBudgetUseCase(getIt<BudgetsRepository>()));
  factory(() => BudgetsCubit(
        watchBudgets: getIt<WatchBudgetsUseCase>(),
        saveBudget: getIt<SaveBudgetUseCase>(),
        deleteBudget: getIt<DeleteBudgetUseCase>(),
      ));

  single<JarsLocalDataSource>(() => JarsLocalDataSourceImpl(finance: fin));
  single<JarsRepository>(
      () => JarsRepositoryImpl(localDataSource: getIt<JarsLocalDataSource>()));
  single(() => WatchJarsUseCase(getIt<JarsRepository>()));
  single(() => AddJarUseCase(getIt<JarsRepository>()));
  single(() => DeleteJarUseCase(getIt<JarsRepository>()));
  single(() => DepositJarUseCase(getIt<JarsRepository>()));
  factory(() => JarsCubit(
        watchJars: getIt<WatchJarsUseCase>(),
        addJar: getIt<AddJarUseCase>(),
        deleteJar: getIt<DeleteJarUseCase>(),
        depositJar: getIt<DepositJarUseCase>(),
      ));

  single<SchedulesLocalDataSource>(
      () => SchedulesLocalDataSourceImpl(finance: fin));
  single<SchedulesRepository>(() => SchedulesRepositoryImpl(
      localDataSource: getIt<SchedulesLocalDataSource>()));
  single(() => WatchSchedulesUseCase(getIt<SchedulesRepository>()));
  single(() => SaveScheduleUseCase(getIt<SchedulesRepository>()));
  single(() => ToggleScheduleUseCase(getIt<SchedulesRepository>()));
  single(() => DeleteScheduleUseCase(getIt<SchedulesRepository>()));
  single(() => ExecuteScheduleNowUseCase(getIt<SchedulesRepository>()));
  single(() => ProcessDueSchedulesUseCase(getIt<SchedulesRepository>()));
  factory(() => SchedulesCubit(
        watchSchedules: getIt<WatchSchedulesUseCase>(),
        saveSchedule: getIt<SaveScheduleUseCase>(),
        toggleSchedule: getIt<ToggleScheduleUseCase>(),
        deleteSchedule: getIt<DeleteScheduleUseCase>(),
        executeNow: getIt<ExecuteScheduleNowUseCase>(),
      ));

  // 4g. Analytics
  single<AnalyticsLocalDataSource>(
      () => AnalyticsLocalDataSourceImpl(finance: fin));
  single<AnalyticsRepository>(() => AnalyticsRepositoryImpl(
      localDataSource: getIt<AnalyticsLocalDataSource>()));
  single(() => WatchSummaryUseCase(getIt<AnalyticsRepository>()));
  single(() => WatchExpenseByCategoryUseCase(getIt<AnalyticsRepository>()));
  single(() => WatchDailyUseCase(getIt<AnalyticsRepository>()));
  single(() => GetCategoryTransactionsUseCase(getIt<AnalyticsRepository>()));
  factory(() => AnalyticsCubit(
        watchWallets: getIt<WatchWalletsUseCase>(),
        watchSummary: getIt<WatchSummaryUseCase>(),
        watchExpenseByCategory: getIt<WatchExpenseByCategoryUseCase>(),
        watchDaily: getIt<WatchDailyUseCase>(),
        getCategoryTransactions: getIt<GetCategoryTransactionsUseCase>(),
      ));

  // 4i. Profile
  single<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl(backup: getIt<BackupService>()));
  single<ProfileRepository>(() => ProfileRepositoryImpl(
      localDataSource: getIt<ProfileLocalDataSource>()));
  single(() => GetCachedProfileUseCase(getIt<ProfileRepository>()));
  single(() => ExportJsonUseCase(getIt<ProfileRepository>()));
  single(() => ExportCsvUseCase(getIt<ProfileRepository>()));
  single(() => ImportJsonUseCase(getIt<ProfileRepository>()));
  single(() => ClearAllDataUseCase(getIt<ProfileRepository>()));
  factory(() => ProfileCubit(
        getCachedProfile: getIt<GetCachedProfileUseCase>(),
        exportJson: getIt<ExportJsonUseCase>(),
        exportCsv: getIt<ExportCsvUseCase>(),
        importJson: getIt<ImportJsonUseCase>(),
        clearAll: getIt<ClearAllDataUseCase>(),
      ));

  // 4h. Home
  factory(() => HomeCubit(
        watchWallets: getIt<WatchWalletsUseCase>(),
        watchCategories: getIt<WatchCategoriesUseCase>(),
        watchSummary: getIt<WatchSummaryUseCase>(),
      ));
}

@module
abstract class RegisterModule {
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;

  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
