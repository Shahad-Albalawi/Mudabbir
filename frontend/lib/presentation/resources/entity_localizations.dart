import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Maps default Arabic DB labels to English for display when locale is EN.
class EntityLocalizations {
  EntityLocalizations._();

  static const _categories = <String, String>{
    'راتب': 'Salary',
    'مكافأة': 'Bonus',
    'هبه': 'Gift',
    'اخرى': 'Other',
    'طعام': 'Food',
    'نقل': 'Transport',
    'تسوق': 'Shopping',
    'فواتير': 'Bills',
    'صحة': 'Health',
    'ترفيه': 'Entertainment',
  };

  static const _accounts = <String, String>{'النقدية': 'Cash', 'البنك': 'Bank'};

  static const _challengeStatus = <String, String>{
    'نشط': 'Active',
    'مكتمل': 'Completed',
    'ملغي': 'Cancelled',
  };

  static String categoryName(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (AppStrings.isEnglishLocale) {
      return _categories[raw] ?? raw;
    }
    return raw;
  }

  static String accountName(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (AppStrings.isEnglishLocale) {
      return _accounts[raw] ?? raw;
    }
    return raw;
  }

  static String challengeStatusLabel(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    if (AppStrings.isEnglishLocale) {
      return _challengeStatus[raw] ?? raw;
    }
    return raw;
  }
}
