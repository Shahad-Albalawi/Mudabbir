import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Maps default Arabic DB labels to localized display names via [AppStrings].
class EntityLocalizations {
  EntityLocalizations._();

  /// Arabic keys stored in SQLite for default categories.
  static const categorySalaryDbName = 'راتب';
  static const categoryOtherDbName = 'اخرى';

  static const challengeStatusActiveKey = 'نشط';
  static const challengeStatusCompletedKey = 'مكتمل';
  static const challengeStatusCancelledKey = 'ملغي';

  static const _categoryEmojis = <String, String>{
    'طعام': '🍽️',
    'نقل': '🚗',
    'تسوق': '🛍️',
    'فواتير': '🧾',
    'صحة': '💊',
    'ترفيه': '🎬',
    'راتب': '💰',
    'مكافأة': '🎁',
    'هبه': '🎁',
    'اخرى': '📌',
  };

  /// English labels that may appear in legacy rows → Arabic DB keys for emoji lookup.
  static const _englishCategoryDbKeys = <String, String>{
    'Salary': categorySalaryDbName,
    'Bonus': 'مكافأة',
    'Gift': 'هبه',
    'Other': categoryOtherDbName,
    'Food': 'طعام',
    'Transport': 'نقل',
    'Shopping': 'تسوق',
    'Bills': 'فواتير',
    'Health': 'صحة',
    'Entertainment': 'ترفيه',
  };

  static String categoryEmoji(String? raw) {
    if (raw == null || raw.isEmpty) return '📊';
    final dbKey = _categoryDbKey(raw);
    if (dbKey != null) return _categoryEmojis[dbKey] ?? '📊';
    return '📊';
  }

  static String categoryName(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dbKey = _categoryDbKey(raw);
    if (dbKey == null) return raw;
    return _localizedCategory(dbKey);
  }

  static String accountName(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return switch (raw) {
      'النقدية' || 'Cash' => AppStrings.entityAccountCash,
      'البنك' || 'Bank' => AppStrings.entityAccountBank,
      _ => raw,
    };
  }

  static String challengeStatusLabel(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    return switch (raw) {
      challengeStatusActiveKey || 'Active' =>
        AppStrings.challengeStatusActiveLabel,
      challengeStatusCompletedKey || 'Completed' =>
        AppStrings.challengeStatusCompletedLabel,
      challengeStatusCancelledKey || 'Cancelled' =>
        AppStrings.challengeStatusCancelledLabel,
      _ => raw,
    };
  }

  static String? _categoryDbKey(String raw) {
    return switch (raw) {
      categorySalaryDbName || 'Salary' => categorySalaryDbName,
      'مكافأة' || 'Bonus' => 'مكافأة',
      'هبه' || 'Gift' => 'هبه',
      categoryOtherDbName || 'Other' => categoryOtherDbName,
      'طعام' || 'Food' => 'طعام',
      'نقل' || 'Transport' => 'نقل',
      'تسوق' || 'Shopping' => 'تسوق',
      'فواتير' || 'Bills' => 'فواتير',
      'صحة' || 'Health' => 'صحة',
      'ترفيه' || 'Entertainment' => 'ترفيه',
      _ => _englishCategoryDbKeys[raw],
    };
  }

  static String _localizedCategory(String dbKey) {
    return switch (dbKey) {
      categorySalaryDbName => AppStrings.entityCatSalary,
      'مكافأة' => AppStrings.entityCatBonus,
      'هبه' => AppStrings.entityCatGift,
      categoryOtherDbName => AppStrings.entityCatOther,
      'طعام' => AppStrings.entityCatFood,
      'نقل' => AppStrings.entityCatTransport,
      'تسوق' => AppStrings.entityCatShopping,
      'فواتير' => AppStrings.entityCatBills,
      'صحة' => AppStrings.entityCatHealth,
      'ترفيه' => AppStrings.entityCatEntertainment,
      _ => dbKey,
    };
  }
}
