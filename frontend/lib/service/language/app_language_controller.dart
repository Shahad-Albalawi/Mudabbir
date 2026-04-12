import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists app language selection (Arabic / English).
class AppLanguageController extends ChangeNotifier {
  static const _prefsKey = 'mudabbir_locale';

  Locale _locale = const Locale('ar');
  Locale get locale => _locale;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString(_prefsKey) ?? 'ar';
    _locale = Locale(code == 'en' ? 'en' : 'ar');
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    final safeCode = languageCode == 'en' ? 'en' : 'ar';
    _locale = Locale(safeCode);
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefsKey, safeCode);
  }

  Future<void> cycleLocale() async {
    await setLocale(_locale.languageCode == 'ar' ? 'en' : 'ar');
  }
}
