import 'package:get_it/get_it.dart';
import 'package:mudabbir/data/local/budget_hive_cache.dart';
import 'package:mudabbir/data/local/challenge_hive_cache.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/data/local/local_database.dart';
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
import 'package:mudabbir/presentation/server_challenges/services/challenge_service.dart';
import 'package:mudabbir/data/network/dio_client.dart';
import 'package:mudabbir/features/auth/services/auth_service.dart';
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

GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<AuthTokenSecureStore>(
    () => AuthTokenSecureStore(),
  );
  getIt.registerLazySingleton<AppLanguageController>(
    () => AppLanguageController(),
  );
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<AuthNotifier>(() => AuthNotifier());
  getIt.registerLazySingleton<HiveService>(() => HiveService());
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<LocalDatabase>(() => LocalDatabase.instance);
  getIt.registerLazySingleton<DbHelper>(() => DbHelper(getIt<LocalDatabase>()));
  getIt.registerLazySingleton<ReportService>(() => ReportService());
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepository());
  getIt.registerLazySingleton<PopupService>(() => PopupService());
  getIt.registerLazySingleton<BudgetRepository>(() => BudgetRepository());
  getIt.registerLazySingleton<ExpenseRepository>(() => ExpenseRepository());
  getIt.registerLazySingleton<BehavioralAnalysisRepository>(
    () => BehavioralAnalysisRepository(),
  );
  getIt.registerLazySingleton<GoalsRepository>(() => GoalsRepository());
  getIt.registerLazySingleton<TransactionPopup>(() => TransactionPopup());
  getIt.registerLazySingleton<BudgetPopup>(() => BudgetPopup());
  getIt.registerLazySingleton<GoalPopup>(() => GoalPopup());
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  getIt.registerLazySingleton<ChallengeService>(
    () => ChallengeService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<ChallengeHiveCache>(() => ChallengeHiveCache());
  getIt.registerLazySingleton<ServerChallengeRepository>(
    () => ServerChallengeRepository(),
  );
  getIt.registerLazySingleton<BudgetHiveCache>(() => BudgetHiveCache());
  getIt.registerLazySingleton<ExpenseHiveCache>(() => ExpenseHiveCache());
  getIt.registerLazySingleton<GoalHiveCache>(() => GoalHiveCache());
  getIt.registerLazySingleton<ExpenseApiService>(
    () => ExpenseApiService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<BudgetApiService>(
    () => BudgetApiService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<GoalApiService>(
    () => GoalApiService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<NotificationApiService>(
    () => NotificationApiService(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<SyncedBudgetRepository>(
    () => SyncedBudgetRepository(),
  );
  getIt.registerLazySingleton<SyncedExpenseRepository>(
    () => SyncedExpenseRepository(),
  );
  getIt.registerLazySingleton<SyncedGoalsRepository>(
    () => SyncedGoalsRepository(),
  );
}
