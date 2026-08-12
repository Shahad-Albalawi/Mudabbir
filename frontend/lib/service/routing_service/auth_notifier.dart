import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/local/budget_hive_cache.dart';
import 'package:mudabbir/data/local/challenge_hive_cache.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/service/debug/demo_seed_service.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/notifications/push_notification_service.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';
import 'package:mudabbir/utils/dev_log.dart';
import 'package:mudabbir/utils/local_db_user_id.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_flags.dart';
import 'package:mudabbir/constants/test_support.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier({
    required HiveService hiveService,
    required AuthTokenSecureStore secureStore,
    required ExpenseHiveCache expenseCache,
    required GoalHiveCache goalCache,
    required BudgetHiveCache budgetCache,
    required ChallengeHiveCache challengeCache,
  })  : _hiveService = hiveService,
        _secureStore = secureStore,
        _expenseCache = expenseCache,
        _goalCache = goalCache,
        _budgetCache = budgetCache,
        _challengeCache = challengeCache {
    _checkLoginStatusAtStartup();
  }

  final HiveService _hiveService;
  final AuthTokenSecureStore _secureStore;
  final ExpenseHiveCache _expenseCache;
  final GoalHiveCache _goalCache;
  final BudgetHiveCache _budgetCache;
  final ChallengeHiveCache _challengeCache;

  bool _isLoggedIn = false;
  bool _isInitialized = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  Future<void> _checkLoginStatusAtStartup() async {
    final tokenStr = await _secureStore.readToken();

    if (tokenStr != null && tokenStr.isNotEmpty) {
      final user = _hiveService.getValue(HiveConstants.savedUserInfo);
      if (user != null && user is Map) {
        _isLoggedIn = true;
        if (!TestSupport.skipDatabaseSideEffects) {
          await LocalDatabase.instance.initForUser(resolveLocalDbUserId(user));
          if (AppFlags.enableDemoSeed) {
            await DemoSeedService.seedIfDatabaseEmpty();
          }
        }
        devLog('Database initialized for existing user: ${user['name']}');
      } else {
        await _secureStore.clearToken();
        await _hiveService.deleteValue(HiveConstants.savedToken);
        _isLoggedIn = false;
      }
    } else {
      _isLoggedIn = false;
      await _hiveService.deleteValue(HiveConstants.savedToken);
      if (AppFlags.allowGuestHome) {
        if (!TestSupport.skipDatabaseSideEffects) {
          final guestUser = resolveLocalDbUserId(
            _hiveService.getValue(HiveConstants.savedUserInfo),
          );
          await LocalDatabase.instance.initForUser(guestUser);
          if (AppFlags.enableDemoSeed) {
            await DemoSeedService.seedIfDatabaseEmpty();
          }
        }
      } else {
        if (!TestSupport.skipDatabaseSideEffects) {
          await LocalDatabase.instance.close();
        }
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> didLogin(Map<String, dynamic> user, String token) async {
    try {
      await _secureStore.writeToken(token);
      await _hiveService.setValue(HiveConstants.savedUserInfo, user);
      await _hiveService.deleteValue(HiveConstants.savedToken);

      final dbUserId = resolveLocalDbUserId(user);
      if (!TestSupport.skipDatabaseSideEffects) {
        await LocalDatabase.instance.initForUser(dbUserId);
        if (AppFlags.enableDemoSeed) {
          await DemoSeedService.seedIfDatabaseEmpty();
        }
      }
      devLog('Database initialized for new user: $dbUserId');

      _isLoggedIn = true;
      notifyListeners();
      devLog('Auth state updated: isLoggedIn = $_isLoggedIn');
    } catch (e) {
      devLog('Error during login: $e');
      await _hiveService.deleteValue(HiveConstants.savedUserInfo);
      await _secureStore.clearToken();
      _isLoggedIn = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> didLogout() async {
    await PushNotificationService.instance.unregisterFromBackend();
    await _hiveService.deleteValue(HiveConstants.savedUserInfo);
    await _hiveService.deleteValue(HiveConstants.savedToken);
    await _secureStore.clearToken();

    await _expenseCache.clearAll();
    await _goalCache.clearAll();
    await _budgetCache.clearAll();
    await _challengeCache.clearAll();

    if (AppFlags.allowGuestHome) {
      if (!TestSupport.skipDatabaseSideEffects) {
        await LocalDatabase.instance.initForUser('guest_user');
        if (AppFlags.enableDemoSeed) {
          await DemoSeedService.seedIfDatabaseEmpty();
        }
      }
    } else {
      if (!TestSupport.skipDatabaseSideEffects) {
        await LocalDatabase.instance.close();
      }
    }

    _isLoggedIn = false;
    notifyListeners();
  }
}
