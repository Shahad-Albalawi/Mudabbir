import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/constants/test_support.dart';
import 'package:mudabbir/core/providers/app_bootstrap.dart';
import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/core/providers/provider_reader.dart';
import 'package:mudabbir/data/local/budget_hive_cache.dart';
import 'package:mudabbir/data/local/challenge_hive_cache.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/domain/repository/user_repository/user_repository.dart';
import 'package:mudabbir/features/auth/services/auth_service.dart';
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

ProviderContainer? _authTestContainer;
FakeHiveService? _fakeHive;

ProviderContainer get authTestContainer {
  final container = _authTestContainer;
  if (container == null) {
    throw StateError('Call bootstrapAuthIntegrationTests() first');
  }
  return container;
}

Future<void> bootstrapAuthIntegrationTests() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestSupport.skipDatabaseSideEffects = true;
  await resetAuthTestLocator();
}

Future<void> resetAuthTestLocator() async {
  _authTestContainer?.dispose();
  _fakeHive = FakeHiveService();

  _authTestContainer = createTestContainer(
    overrides: [
      hiveServiceProvider.overrideWithValue(_fakeHive!),
      authTokenSecureStoreProvider.overrideWithValue(AuthTokenSecureStore()),
      expenseHiveCacheProvider.overrideWithValue(FakeExpenseHiveCache()),
      goalHiveCacheProvider.overrideWithValue(FakeGoalHiveCache()),
      budgetHiveCacheProvider.overrideWithValue(FakeBudgetHiveCache()),
      challengeHiveCacheProvider.overrideWithValue(FakeChallengeHiveCache()),
    ],
  );
}

void registerMockUserRepository(UserRepository mock) {
  final container = authTestContainer;
  container.dispose();
  _authTestContainer = createTestContainer(
    overrides: [
      hiveServiceProvider.overrideWithValue(_fakeHive!),
      authTokenSecureStoreProvider.overrideWithValue(AuthTokenSecureStore()),
      expenseHiveCacheProvider.overrideWithValue(FakeExpenseHiveCache()),
      goalHiveCacheProvider.overrideWithValue(FakeGoalHiveCache()),
      budgetHiveCacheProvider.overrideWithValue(FakeBudgetHiveCache()),
      challengeHiveCacheProvider.overrideWithValue(FakeChallengeHiveCache()),
      userRepositoryProvider.overrideWithValue(mock),
    ],
  );
}

AuthNotifier readAuthNotifier() => authTestContainer.read(authNotifierProvider);

AuthService readAuthService() => authTestContainer.read(authServiceProvider);

HiveService readTestHiveService() => _fakeHive!;

AuthTokenSecureStore readTestSecureStore() =>
    authTestContainer.read(authTokenSecureStoreProvider);

Future<void> waitForAuthNotifierInit(AuthNotifier auth) async {
  for (var i = 0; i < 100 && !auth.isInitialized; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  expect(auth.isInitialized, isTrue);
}

Future<void> disposeAuthTestLocator() async {
  _authTestContainer?.dispose();
  _authTestContainer = null;
  _fakeHive = null;
  resetProviderContainerBinding();
}
