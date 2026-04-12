import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Persists light / dark / system appearance (premium apps let users override OS).
class AppThemeController extends ChangeNotifier {
  static const _prefsKey = 'mudabbir_theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get themeMode => _mode;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _mode = switch (p.getString(_prefsKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _prefsKey,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        _ => 'system',
      },
    );
  }

  /// System → Light → Dark → System
  Future<void> cycleTheme() async {
    final next = switch (_mode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setThemeMode(next);
  }
}
