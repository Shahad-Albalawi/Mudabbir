import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/l10n/app_localizations.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

void main() {
  group('AppLocalizations', () {
    test('Arabic and English differ for login welcome', () {
      final ar = lookupAppLocalizations(const Locale('ar'));
      final en = lookupAppLocalizations(const Locale('en'));
      expect(ar.loginWelcome, 'مرحباً بعودتك');
      expect(en.loginWelcome, 'Welcome back');
    });

    test('AppStrings uses bound locale via lookup fallback', () {
      AppStrings.bind(lookupAppLocalizations(const Locale('en')));
      expect(AppStrings.isEnglishLocale, isTrue);
      expect(AppStrings.validationEmailRequired, 'Email is required');
      AppStrings.bind(lookupAppLocalizations(const Locale('ar')));
      expect(AppStrings.validationEmailRequired, 'البريد الإلكتروني مطلوب');
    });
  });
}
