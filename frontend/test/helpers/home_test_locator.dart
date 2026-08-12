import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/core/providers/app_bootstrap.dart';
import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/core/providers/provider_reader.dart';
import 'package:mudabbir/data/local/budget_hive_cache.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/data/remote/notification_api_service.dart';
import 'package:mudabbir/domain/models/app_notification.dart';
import 'package:mudabbir/domain/repository/home_repository/home_repository.dart';
import 'package:mudabbir/domain/repository/synced_expense_repository/synced_expense_repository.dart';
import 'package:mudabbir/domain/repository/synced_goals_repository/synced_goals_repository.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mockito/mockito.dart';

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
ProviderContainer? _homeTestContainer;

/// Minimal Riverpod setup for [HomeScreen] widget tests (no SQLite native assets).
Future<void> bootstrapHomeWidgetTests() async {
  if (_homeLocatorReady) return;
  TestWidgetsFlutterBinding.ensureInitialized();

  _homeTestContainer?.dispose();
  _homeTestContainer = createTestContainer(
    overrides: [
      dbHelperProvider.overrideWithValue(MockDbHelper()),
      homeRepositoryProvider.overrideWithValue(MockHomeRepository()),
      syncedExpenseRepositoryProvider.overrideWithValue(
        MockSyncedExpenseRepository(),
      ),
      syncedGoalsRepositoryProvider.overrideWithValue(
        MockSyncedGoalsRepository(),
      ),
      hiveServiceProvider.overrideWithValue(MockHiveService()),
      expenseHiveCacheProvider.overrideWithValue(FakeExpenseHiveCache()),
      goalHiveCacheProvider.overrideWithValue(FakeGoalHiveCache()),
      budgetHiveCacheProvider.overrideWithValue(FakeBudgetHiveCache()),
      notificationApiServiceProvider.overrideWithValue(
        FakeNotificationApiService(),
      ),
    ],
  );

  _homeLocatorReady = true;
}

/// Disposes the shared test container — call from tearDownAll if needed.
Future<void> disposeHomeWidgetTests() async {
  _homeTestContainer?.dispose();
  _homeTestContainer = null;
  resetProviderContainerBinding();
  _homeLocatorReady = false;
}
