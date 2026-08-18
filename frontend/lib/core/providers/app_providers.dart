import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/local/budget_hive_cache.dart';
import 'package:mudabbir/data/local/challenge_hive_cache.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/data/network/dio_client.dart';
import 'package:mudabbir/data/remote/analytics_api_service.dart';
import 'package:mudabbir/data/remote/budget_api_service.dart';
import 'package:mudabbir/data/remote/expense_api_service.dart';
import 'package:mudabbir/data/remote/goal_api_service.dart';
import 'package:mudabbir/data/remote/notification_api_service.dart';
import 'package:mudabbir/domain/repository/behavioral_analysis_repository/behavioral_analysis_repository.dart';
import 'package:mudabbir/domain/repository/budget_repository/budget_repository.dart';
import 'package:mudabbir/domain/repository/expense_repository/expense_repository.dart';
import 'package:mudabbir/domain/repository/goals_repository/goals_repository.dart';
import 'package:mudabbir/domain/repository/home_repository/home_repository.dart';
import 'package:mudabbir/domain/repository/server_challenge_repository/server_challenge_repository.dart';
import 'package:mudabbir/domain/repository/synced_budget_repository/synced_budget_repository.dart';
import 'package:mudabbir/domain/repository/synced_expense_repository/synced_expense_repository.dart';
import 'package:mudabbir/domain/repository/synced_goals_repository/synced_goals_repository.dart';
import 'package:mudabbir/domain/repository/user_repository/user_repository.dart';
import 'package:mudabbir/features/auth/services/auth_service.dart';
import 'package:mudabbir/presentation/server_challenges/services/challenge_service.dart';
import 'package:mudabbir/service/api_service.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/language/app_language_controller.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/popup_service/budget_popup.dart';
import 'package:mudabbir/service/popup_service/goal_popup.dart';
import 'package:mudabbir/service/popup_service/popup_service.dart';
import 'package:mudabbir/service/popup_service/transaction_popup.dart';
import 'package:mudabbir/service/report_service.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';

// ---------------------------------------------------------------------------
// Infrastructure
// ---------------------------------------------------------------------------

final navigationServiceProvider = Provider<NavigationService>((ref) {
  ref.keepAlive();
  return NavigationService();
});

final authTokenSecureStoreProvider = Provider<AuthTokenSecureStore>((ref) {
  ref.keepAlive();
  return AuthTokenSecureStore();
});

final hiveServiceProvider = Provider<HiveService>((ref) {
  ref.keepAlive();
  return HiveService();
});

final appLanguageControllerProvider =
    ChangeNotifierProvider<AppLanguageController>((ref) {
  ref.keepAlive();
  return AppLanguageController();
});

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  ref.keepAlive();
  return LocalDatabase.instance;
});

final dbHelperProvider = Provider<DbHelper>((ref) {
  return DbHelper(ref.watch(localDatabaseProvider));
});

final challengeHiveCacheProvider = Provider<ChallengeHiveCache>((ref) {
  ref.keepAlive();
  return ChallengeHiveCache();
});

final expenseHiveCacheProvider = Provider<ExpenseHiveCache>((ref) {
  ref.keepAlive();
  return ExpenseHiveCache();
});

final budgetHiveCacheProvider = Provider<BudgetHiveCache>((ref) {
  ref.keepAlive();
  return BudgetHiveCache();
});

final goalHiveCacheProvider = Provider<GoalHiveCache>((ref) {
  ref.keepAlive();
  return GoalHiveCache();
});

// ---------------------------------------------------------------------------
// Auth & HTTP (single Dio instance)
// ---------------------------------------------------------------------------

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  ref.keepAlive();
  return AuthNotifier(
    hiveService: ref.watch(hiveServiceProvider),
    secureStore: ref.watch(authTokenSecureStoreProvider),
    expenseCache: ref.watch(expenseHiveCacheProvider),
    goalCache: ref.watch(goalHiveCacheProvider),
    budgetCache: ref.watch(budgetHiveCacheProvider),
    challengeCache: ref.watch(challengeHiveCacheProvider),
  );
});

final dioClientProvider = Provider<DioClient>((ref) {
  ref.keepAlive();
  return DioClient(
    secureStore: ref.watch(authTokenSecureStoreProvider),
    onUnauthorized: () async {
      await ref.read(authNotifierProvider).didLogout();
    },
  );
});

final analyticsApiServiceProvider = Provider<AnalyticsApiService>((ref) {
  return AnalyticsApiService(ref.watch(dioClientProvider));
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(
    dio: ref.watch(dioClientProvider).dio,
    hiveService: ref.watch(hiveServiceProvider),
    secureStore: ref.watch(authTokenSecureStoreProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiServiceProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    userRepository: ref.watch(userRepositoryProvider),
    secureStore: ref.watch(authTokenSecureStoreProvider),
    authNotifier: ref.watch(authNotifierProvider),
    hiveService: ref.watch(hiveServiceProvider),
    apiService: ref.watch(apiServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Domain repositories
// ---------------------------------------------------------------------------

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(db: ref.watch(dbHelperProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(db: ref.watch(dbHelperProvider));
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(db: ref.watch(dbHelperProvider));
});

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return GoalsRepository(db: ref.watch(dbHelperProvider));
});

final behavioralAnalysisRepositoryProvider =
    Provider<BehavioralAnalysisRepository>((ref) {
  return BehavioralAnalysisRepository(db: ref.watch(dbHelperProvider));
});

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(
    db: ref.watch(dbHelperProvider),
    hiveService: ref.watch(hiveServiceProvider),
  );
});

// ---------------------------------------------------------------------------
// Remote API services (all share [dioClientProvider])
// ---------------------------------------------------------------------------

final expenseApiServiceProvider = Provider<ExpenseApiService>((ref) {
  return ExpenseApiService(ref.watch(dioClientProvider));
});

final budgetApiServiceProvider = Provider<BudgetApiService>((ref) {
  return BudgetApiService(ref.watch(dioClientProvider));
});

final goalApiServiceProvider = Provider<GoalApiService>((ref) {
  return GoalApiService(ref.watch(dioClientProvider));
});

final notificationApiServiceProvider = Provider<NotificationApiService>((ref) {
  return NotificationApiService(ref.watch(dioClientProvider));
});

final challengeServiceProvider = Provider<ChallengeService>((ref) {
  return ChallengeService(ref.watch(dioClientProvider));
});

final serverChallengeRepositoryProvider =
    Provider<ServerChallengeRepository>((ref) {
  return ServerChallengeRepository(
    remote: ref.watch(challengeServiceProvider),
    cache: ref.watch(challengeHiveCacheProvider),
  );
});

final syncedExpenseRepositoryProvider =
    Provider<SyncedExpenseRepository>((ref) {
  return SyncedExpenseRepository(
    local: ref.watch(expenseRepositoryProvider),
    remote: ref.watch(expenseApiServiceProvider),
    cache: ref.watch(expenseHiveCacheProvider),
  );
});

final syncedBudgetRepositoryProvider = Provider<SyncedBudgetRepository>((ref) {
  return SyncedBudgetRepository(
    local: ref.watch(budgetRepositoryProvider),
    remote: ref.watch(budgetApiServiceProvider),
    cache: ref.watch(budgetHiveCacheProvider),
  );
});

final syncedGoalsRepositoryProvider = Provider<SyncedGoalsRepository>((ref) {
  return SyncedGoalsRepository(
    local: ref.watch(goalsRepositoryProvider),
    remote: ref.watch(goalApiServiceProvider),
    cache: ref.watch(goalHiveCacheProvider),
  );
});

// ---------------------------------------------------------------------------
// UI popups
// ---------------------------------------------------------------------------

final transactionPopupProvider = Provider<TransactionPopup>((ref) {
  return TransactionPopup(
    expenseRepository: ref.watch(expenseRepositoryProvider),
    hiveService: ref.watch(hiveServiceProvider),
  );
});

final budgetPopupProvider = Provider<BudgetPopup>((ref) {
  return BudgetPopup();
});

final goalPopupProvider = Provider<GoalPopup>((ref) {
  return GoalPopup();
});

final popupServiceProvider = Provider<PopupService>((ref) {
  return PopupService(
    transactionPopup: ref.watch(transactionPopupProvider),
    budgetPopup: ref.watch(budgetPopupProvider),
    goalPopup: ref.watch(goalPopupProvider),
  );
});
