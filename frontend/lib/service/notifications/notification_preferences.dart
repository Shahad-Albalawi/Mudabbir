import 'package:shared_preferences/shared_preferences.dart';

/// User preference for budget/goal local notifications.
class NotificationPreferences {
  NotificationPreferences._();

  static const _key = 'mudabbir_notifications_enabled';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}
