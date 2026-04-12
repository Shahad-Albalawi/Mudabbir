import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/domain/repository/budget_repository/budget_repository.dart';
import 'package:mudabbir/domain/repository/challanges_repository/challanges_repository.dart';
import 'package:mudabbir/domain/repository/goals_repository/goals_repository.dart';
import 'package:mudabbir/domain/repository/home_repository/home_repository.dart';
import 'package:mudabbir/domain/repository/planner_repository/planner_repository.dart';
import 'package:mudabbir/domain/repository/post_repository/posts_repository.dart';
import 'package:mudabbir/persentation/chatbot/chatbot_viewmodel.dart';
import 'package:mudabbir/service/popup_service/budget_popup.dart';
import 'package:mudabbir/service/popup_service/challenge_popup.dart';
import 'package:mudabbir/service/popup_service/goal_popup.dart';
import 'package:mudabbir/service/popup_service/popup_service.dart';
import 'package:mudabbir/service/popup_service/transaction_popup.dart';
import 'package:mudabbir/service/posts_service/posts_service.dart';
import 'package:mudabbir/service/reporting/financial_report_service.dart';
import 'package:get_it/get_it.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/api_service.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';
import 'package:mudabbir/service/language/app_language_controller.dart';
import 'package:mudabbir/service/theme/app_theme_controller.dart';
import 'package:mudabbir/domain/repository/user_repository/user_repository.dart';

GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<AuthTokenSecureStore>(() => AuthTokenSecureStore());
  getIt.registerLazySingleton<AppThemeController>(() => AppThemeController());
  getIt.registerLazySingleton<AppLanguageController>(
    () => AppLanguageController(),
  );
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<AuthNotifier>(() => AuthNotifier());
  getIt.registerLazySingleton<HiveService>(() => HiveService());
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<ApiService>()),
  );
  // Our new database singletons
  getIt.registerLazySingleton<LocalDatabase>(() => LocalDatabase.instance);
  getIt.registerLazySingleton<DbHelper>(() => DbHelper(getIt<LocalDatabase>()));
  getIt.registerLazySingleton<PostRepository>(() => PostRepository());
  getIt.registerLazySingleton<PostService>(() => PostService());
  getIt.registerLazySingleton<FinancialReportService>(
    () => FinancialReportService(),
  );
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepository());
  getIt.registerLazySingleton<PlannerRepository>(() => PlannerRepository());

  getIt.registerLazySingleton<PopupService>(() => PopupService());
  getIt.registerLazySingleton<BudgetRepository>(() => BudgetRepository());
  getIt.registerLazySingleton<GoalsRepository>(() => GoalsRepository());
  getIt.registerLazySingleton<TransactionPopup>(() => TransactionPopup());
  getIt.registerLazySingleton<ChallengePopup>(() => ChallengePopup());
  getIt.registerLazySingleton<BudgetPopup>(() => BudgetPopup());
  getIt.registerLazySingleton<GoalPopup>(() => GoalPopup());
  getIt.registerLazySingleton<ChallengesRepository>(
    () => ChallengesRepository(),
  );
  getIt.registerLazySingleton<ChatbotViewModel>(() => ChatbotViewModel());
}
