import 'package:hive_flutter/hive_flutter.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/core/providers/provider_reader.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding completion — [onboardedKey] in SharedPreferences (+ Hive sync).
abstract final class OnboardingPrefs {
  OnboardingPrefs._();

  static const onboardedKey = 'onboarded';

  /// Legacy keys migrated on read.
  static const _legacyPrefsKey = 'onboarding_complete';
  static const _legacyHiveKey = HiveConstants.onboardingSeenKey;

  static Future<bool> hasOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(onboardedKey) == true) return true;

    if (Hive.isBoxOpen(HiveConstants.prefsBox)) {
      final hiveSeen = Hive.box(HiveConstants.prefsBox)
          .get(_legacyHiveKey, defaultValue: false);
      if (hiveSeen == true) {
        await prefs.setBool(onboardedKey, true);
        return true;
      }
    }

    if (prefs.getBool(_legacyPrefsKey) == true) {
      await _syncAll(true);
      return true;
    }

    if (readApp(hiveServiceProvider).getValue(HiveConstants.savedFirstTime) == true) {
      await _syncAll(true);
      return true;
    }

    return false;
  }

  static Future<void> markOnboarded() => _syncAll(true);

  static Future<void> _syncAll(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardedKey, value);
    if (Hive.isBoxOpen(HiveConstants.prefsBox)) {
      await Hive.box(HiveConstants.prefsBox).put(_legacyHiveKey, value);
    }
    await readApp(hiveServiceProvider).setValue(HiveConstants.savedFirstTime, value);
  }
}
