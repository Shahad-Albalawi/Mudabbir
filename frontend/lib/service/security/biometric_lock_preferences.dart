import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the user enabled biometric app lock.
class BiometricLockPreferences {
  BiometricLockPreferences._();

  static const _enabledKey = 'biometric_lock_enabled';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }
}
