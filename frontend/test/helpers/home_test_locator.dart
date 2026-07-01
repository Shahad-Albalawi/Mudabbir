import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mudabbir/data/local/budget_hive_cache.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/data/remote/notification_api_service.dart';
import 'package:mudabbir/domain/models/app_notification.dart';
import 'package:mudabbir/domain/repository/home_repository/home_repository.dart';
import 'package:mudabbir/domain/repository/synced_expense_repository/synced_expense_repository.dart';
import 'package:mudabbir/domain/repository/synced_goals_repository/synced_goals_repository.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';

class MockDbHelper extends Mock implements DbHelper {}

class MockHomeRepository extends Mock implements HomeRepository {}

class MockSyncedExpenseRepository extends Mock implements SyncedExpenseRepository {}

class MockSyncedGoalsRepository extends Mock implements SyncedGoalsRepository {}

class MockHiveService extends Mock implements HiveService {}

class FakeNotificationApiService extends Fake implements NotificationApiService {
  @override
  Future<List<AppNotification>> fetchNotifications() async => [];

  @override
  Future<void> markRead(int id) async {}
}

class FakeExpenseHiveCache extends Fake implements ExpenseHiveCache {
  @override
  List<Map<String, dynamic>> getPendingOps() => const [];
}

class FakeGoalHiveCache extends Fake implements GoalHiveCache {
  @override
  List<Map<String, dynamic>> getPendingOps() => const [];
}

class FakeBudgetHiveCache extends Fake implements BudgetHiveCache {
  @override
  List<Map<String, dynamic>> getPendingOps() => const [];
}

bool _homeLocatorReady = false;

/// Minimal GetIt setup for [HomeScreen] widget tests (no SQLite native assets).
Future<void> bootstrapHomeWidgetTests() async {
  if (_homeLocatorReady) return;
  TestWidgetsFlutterBinding.ensureInitialized();

  await getIt.reset();

  getIt.registerLazySingleton<DbHelper>(() => MockDbHelper());
  getIt.registerLazySingleton<HomeRepository>(() => MockHomeRepository());
  getIt.registerLazySingleton<SyncedExpenseRepository>(
    () => MockSyncedExpenseRepository(),
  );
  getIt.registerLazySingleton<SyncedGoalsRepository>(
    () => MockSyncedGoalsRepository(),
  );
  getIt.registerLazySingleton<HiveService>(() => MockHiveService());
  getIt.registerLazySingleton<ExpenseHiveCache>(() => FakeExpenseHiveCache());
  getIt.registerLazySingleton<GoalHiveCache>(() => FakeGoalHiveCache());
  getIt.registerLazySingleton<BudgetHiveCache>(() => FakeBudgetHiveCache());

  getIt.registerLazySingleton<NotificationApiService>(
    () => FakeNotificationApiService(),
  );

  _homeLocatorReady = true;
}
