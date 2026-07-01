import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const themePrefsKey = 'mudabbir_theme_mode';

/// Persists and exposes light / dark [ThemeMode] for [MaterialApp].
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier({ThemeMode initial = ThemeMode.light}) : super(initial);

  static Future<ThemeMode> loadStored() async {
    final prefs = await SharedPreferences.getInstance();
    return _modeFromString(prefs.getString(themePrefsKey));
  }

  static ThemeMode _modeFromString(String? raw) {
    return switch (raw) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  Future<void> toggle() async {
    state = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    await _persist();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _persist();
  }

  /// Instant light ↔ dark toggle (settings switch).
  Future<void> setDarkEnabled(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (state) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await prefs.setString(themePrefsKey, value);
  }
}
