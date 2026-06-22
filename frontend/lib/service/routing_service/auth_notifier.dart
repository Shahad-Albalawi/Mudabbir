import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/local/budget_hive_cache.dart';
import 'package:mudabbir/data/local/challenge_hive_cache.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/service/debug/demo_seed_service.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';
import 'package:mudabbir/utils/dev_log.dart';
import 'package:mudabbir/utils/local_db_user_id.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_flags.dart';

class AuthNotifier extends ChangeNotifier {
  final HiveService _hiveService = getIt<HiveService>();
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  AuthNotifier() {
    _checkLoginStatusAtStartup();
  }

  Future<void> _checkLoginStatusAtStartup() async {
    final tokenStr = await getIt<AuthTokenSecureStore>().readToken();

    if (tokenStr != null && tokenStr.isNotEmpty) {
      final user = _hiveService.getValue(HiveConstants.savedUserInfo);
      if (user != null && user is Map) {
        _isLoggedIn = true;
        await LocalDatabase.instance.initForUser(resolveLocalDbUserId(user));
        if (AppFlags.enableDemoSeed) {
          await DemoSeedService.seedIfDatabaseEmpty();
        }
        devLog('Database initialized for existing user: ${user['name']}');
      } else {
        await getIt<AuthTokenSecureStore>().clearToken();
        await _hiveService.deleteValue(HiveConstants.savedToken);
        _isLoggedIn = false;
      }
    } else {
      _isLoggedIn = false;
      await _hiveService.deleteValue(HiveConstants.savedToken);
      if (AppFlags.allowGuestHome) {
        final guestUser = resolveLocalDbUserId(
          _hiveService.getValue(HiveConstants.savedUserInfo),
        );
        await LocalDatabase.instance.initForUser(guestUser);
        if (AppFlags.enableDemoSeed) {
          await DemoSeedService.seedIfDatabaseEmpty();
        }
      } else {
        await LocalDatabase.instance.close();
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> didLogin(Map<String, dynamic> user, String token) async {
    try {
      await getIt<AuthTokenSecureStore>().writeToken(token);
      await _hiveService.setValue(HiveConstants.savedUserInfo, user);
      await _hiveService.deleteValue(HiveConstants.savedToken);

      final dbUserId = resolveLocalDbUserId(user);
      await LocalDatabase.instance.initForUser(dbUserId);
      if (AppFlags.enableDemoSeed) {
        await DemoSeedService.seedIfDatabaseEmpty();
      }
      devLog('Database initialized for new user: $dbUserId');

      _isLoggedIn = true;
      notifyListeners();
      devLog('Auth state updated: isLoggedIn = $_isLoggedIn');
    } catch (e) {
      devLog('Error during login: $e');
      await _hiveService.deleteValue(HiveConstants.savedUserInfo);
      await getIt<AuthTokenSecureStore>().clearToken();
      _isLoggedIn = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> didLogout() async {
    await _hiveService.deleteValue(HiveConstants.savedUserInfo);
    await _hiveService.deleteValue(HiveConstants.savedToken);
    await getIt<AuthTokenSecureStore>().clearToken();

    await getIt<ExpenseHiveCache>().clearAll();
    await getIt<GoalHiveCache>().clearAll();
    await getIt<BudgetHiveCache>().clearAll();
    await getIt<ChallengeHiveCache>().clearAll();

    if (AppFlags.allowGuestHome) {
      await LocalDatabase.instance.initForUser('guest_user');
      if (AppFlags.enableDemoSeed) {
        await DemoSeedService.seedIfDatabaseEmpty();
      }
    } else {
      await LocalDatabase.instance.close();
    }

    _isLoggedIn = false;
    notifyListeners();
  }
}
