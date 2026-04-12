import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_flags.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/service/debug/demo_seed_service.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';

class AuthNotifier extends ChangeNotifier {
  final HiveService _hiveService = getIt<HiveService>();
  bool _isLoggedIn = false;
  bool _isInitialized = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;

  /// The constructor is the entry point for this class.
  AuthNotifier() {
    _checkLoginStatusAtStartup();
  }

  /// This private method runs only once when the app starts.
  Future<void> _checkLoginStatusAtStartup() async {
    final raw = _hiveService.getValue(HiveConstants.savedToken);
    String? tokenStr = raw is String && raw.isNotEmpty ? raw : null;

    if (tokenStr == null) {
      final fromSecure = await getIt<AuthTokenSecureStore>().readToken();
      if (fromSecure != null && fromSecure.isNotEmpty) {
        await _hiveService.setValue(HiveConstants.savedToken, fromSecure);
        tokenStr = fromSecure;
      }
    }

    if (tokenStr != null && tokenStr.isNotEmpty) {
      _isLoggedIn = true;

      // Initialize the database for the existing user session.
      final user = _hiveService.getValue(HiveConstants.savedUserInfo);
      if (user != null && user is Map) {
        await LocalDatabase.instance.initForUser(user['name']);
        await DemoSeedService.seedIfDatabaseEmpty();
        debugPrint('Database initialized for existing user: ${user['name']}');
      }
    } else {
      _isLoggedIn = false;
      if (AppFlags.allowGuestHome) {
        await LocalDatabase.instance.initForUser('guest_user');
        await DemoSeedService.seedIfDatabaseEmpty();
      } else {
        await LocalDatabase.instance.close();
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Call this from your LoginView AFTER a successful API login.
  Future<void> didLogin(Map<String, dynamic> user, String token) async {
    try {
      // 1. Save session data to Hive.
      await _hiveService.setValue(HiveConstants.savedToken, token);
      await _hiveService.setValue(HiveConstants.savedUserInfo, user);
      await getIt<AuthTokenSecureStore>().writeToken(token);

      // 2. Initialize the database for the new user session.
      await LocalDatabase.instance.initForUser(user['name']);
      await DemoSeedService.seedIfDatabaseEmpty();
      debugPrint('Database initialized for new user: ${user['name']}');

      // 3. Update the state.
      _isLoggedIn = true;

      // 4. Notify listeners immediately
      notifyListeners();

      debugPrint('Auth state updated: isLoggedIn = $_isLoggedIn');
    } catch (e) {
      debugPrint('Error during login: $e');
      // Rollback on error
      await _hiveService.deleteValue(HiveConstants.savedToken);
      await _hiveService.deleteValue(HiveConstants.savedUserInfo);
      await getIt<AuthTokenSecureStore>().clearToken();
      _isLoggedIn = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Call this from your UI when the user logs out.
  Future<void> didLogout() async {
    // 1. Clear session data from Hive + secure storage.
    await _hiveService.deleteValue(HiveConstants.savedToken);
    await _hiveService.deleteValue(HiveConstants.savedUserInfo);
    await getIt<AuthTokenSecureStore>().clearToken();

    // 2. Guest DB for offline home, or close DB when login is required.
    if (AppFlags.allowGuestHome) {
      await LocalDatabase.instance.initForUser('guest_user');
      await DemoSeedService.seedIfDatabaseEmpty();
    } else {
      await LocalDatabase.instance.close();
    }

    // 3. Update state and notify the router.
    _isLoggedIn = false;
    notifyListeners();
  }

  // Remove the refresh method as it's not needed
}
