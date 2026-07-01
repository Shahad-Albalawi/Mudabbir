import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/constants/test_support.dart';
import 'package:mudabbir/data/local/budget_hive_cache.dart';
import 'package:mudabbir/data/local/challenge_hive_cache.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/domain/repository/user_repository/user_repository.dart';
import 'package:mudabbir/features/auth/services/auth_service.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';

class FakeExpenseHiveCache extends Fake implements ExpenseHiveCache {
  @override
  Future<void> clearAll() async {}

  @override
  List<Map<String, dynamic>> getPendingOps() => const [];
}

class FakeGoalHiveCache extends Fake implements GoalHiveCache {
  @override
  Future<void> clearAll() async {}

  @override
  List<Map<String, dynamic>> getPendingOps() => const [];
}

class FakeBudgetHiveCache extends Fake implements BudgetHiveCache {
  @override
  Future<void> clearAll() async {}

  @override
  List<Map<String, dynamic>> getPendingOps() => const [];
}

class FakeChallengeHiveCache extends Fake implements ChallengeHiveCache {
  @override
  Future<void> clearAll() async {}
}

/// In-memory Hive for auth integration tests.
class FakeHiveService extends Fake implements HiveService {
  final Map<String, dynamic> store = {};

  @override
  dynamic getValue(String key) => store[key];

  @override
  Future<void> setValue(String key, dynamic value) async {
    store[key] = value;
  }

  @override
  Future<void> deleteValue(String key) async {
    store.remove(key);
  }

  @override
  Future<void> clearAll() async {
    store.clear();
  }
}

Future<void> bootstrapAuthIntegrationTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestSupport.skipDatabaseSideEffects = true;
  await resetAuthTestLocator();
}

Future<void> resetAuthTestLocator() async {
  await getIt.reset();

  getIt.registerLazySingleton<HiveService>(() => FakeHiveService());
  getIt.registerLazySingleton<AuthTokenSecureStore>(
    () => AuthTokenSecureStore(),
  );
  getIt.registerLazySingleton<AuthNotifier>(() => AuthNotifier());
  getIt.registerLazySingleton<ExpenseHiveCache>(() => FakeExpenseHiveCache());
  getIt.registerLazySingleton<GoalHiveCache>(() => FakeGoalHiveCache());
  getIt.registerLazySingleton<BudgetHiveCache>(() => FakeBudgetHiveCache());
  getIt.registerLazySingleton<ChallengeHiveCache>(() => FakeChallengeHiveCache());
}

void registerMockUserRepository(UserRepository mock) {
  if (getIt.isRegistered<AuthService>()) {
    getIt.unregister<AuthService>();
  }
  if (getIt.isRegistered<UserRepository>()) {
    getIt.unregister<UserRepository>();
  }
  getIt.registerLazySingleton<UserRepository>(() => mock);
  getIt.registerLazySingleton<AuthService>(() => AuthService());
}

Future<void> waitForAuthNotifierInit(AuthNotifier auth) async {
  for (var i = 0; i < 100 && !auth.isInitialized; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  expect(auth.isInitialized, isTrue);
}
