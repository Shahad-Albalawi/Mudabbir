import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mudabbir/constants/app_flags.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/service/debug/demo_seed_service.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';
import 'package:mudabbir/utils/dev_log.dart';

/// Debug-only: land on home with onboarding done, guest DB + demo rows.
///
/// Turn off with: `--dart-define=DISABLE_INSTANT_BROWSE=true`
class InstantBrowseBootstrap {
  InstantBrowseBootstrap._();

  static const bool _disabled = bool.fromEnvironment(
    'DISABLE_INSTANT_BROWSE',
    defaultValue: false,
  );

  /// Avoid mutating Hive / SQLite when `flutter test` binding is active.
  static bool get _isTestBinding {
    final t = WidgetsBinding.instance.runtimeType.toString();
    return t.contains('Test');
  }

  static bool get isEnabled =>
      kDebugMode && !_disabled && AppFlags.allowGuestHome && !_isTestBinding;

  static Future<void> applyIfEnabled() async {
    if (!isEnabled) return;

    final hive = getIt<HiveService>();
    await hive.setValue(HiveConstants.savedFirstTime, true);

    await hive.deleteValue(HiveConstants.savedToken);
    await getIt<AuthTokenSecureStore>().clearToken();
    await hive.deleteValue(HiveConstants.savedUserInfo);

    // Guest SQLite + neutral demo labels (no real person / PII).
    await hive.setValue(HiveConstants.savedUserInfo, {
      HiveConstants.userInfoLocalDbKey: 'guest_user',
      'name': 'مستخدم تجريبي',
      'email': 'guest@example.com',
    });

    await LocalDatabase.instance.initForUser('guest_user');
    if (AppFlags.enableDemoSeed) {
      await DemoSeedService.forceReapplyGuestDemoData();
    }

    devLog(
      '[InstantBrowse] onboarding skipped, guest session + full demo refill. '
      'Use --dart-define=DISABLE_INSTANT_BROWSE=true to test real flow.',
    );
  }
}
