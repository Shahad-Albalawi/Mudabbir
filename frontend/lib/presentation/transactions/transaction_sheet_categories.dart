import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Preset categories for the add-transaction bottom sheet (4×2 grid).
///
/// [dbName] matches seeded Arabic names in [LocalDatabase].
class TransactionSheetCategory {
  const TransactionSheetCategory({
    required this.label,
    required this.icon,
    required this.dbName,
    required this.types,
  });

  final String label;
  final IconData icon;
  final String dbName;
  final Set<String> types;

  bool supports(String type) => types.contains(type);
}

abstract final class TransactionSheetCategories {
  TransactionSheetCategories._();

  static const sheetTopRadius = 22.0;

  static List<TransactionSheetCategory> get all => [
        TransactionSheetCategory(
          label: AppStrings.txSheetCatShopping,
          icon: Icons.shopping_bag_outlined,
          dbName: 'تسوق',
          types: {'expense'},
        ),
        TransactionSheetCategory(
          label: AppStrings.txSheetCatTransport,
          icon: Icons.directions_car_outlined,
          dbName: 'نقل',
          types: {'expense'},
        ),
        TransactionSheetCategory(
          label: AppStrings.txSheetCatRestaurants,
          icon: Icons.restaurant_outlined,
          dbName: 'طعام',
          types: {'expense'},
        ),
        TransactionSheetCategory(
          label: AppStrings.txSheetCatHealth,
          icon: Icons.medical_services_outlined,
          dbName: 'صحة',
          types: {'expense'},
        ),
        TransactionSheetCategory(
          label: AppStrings.txSheetCatEntertainment,
          icon: Icons.movie_outlined,
          dbName: 'ترفيه',
          types: {'expense'},
        ),
        TransactionSheetCategory(
          label: AppStrings.txSheetCatHousing,
          icon: Icons.home_outlined,
          dbName: 'فواتير',
          types: {'expense'},
        ),
        TransactionSheetCategory(
          label: AppStrings.txSheetCatSalary,
          icon: Icons.payments_outlined,
          dbName: EntityLocalizations.categorySalaryDbName,
          types: {'income'},
        ),
        TransactionSheetCategory(
          label: AppStrings.txSheetCatOther,
          icon: Icons.more_horiz,
          dbName: EntityLocalizations.categoryOtherDbName,
          types: {'expense', 'income'},
        ),
      ];

  static TransactionSheetCategory defaultFor(String type) {
    if (type == 'income') {
      return all.firstWhere(
        (c) => c.dbName == EntityLocalizations.categorySalaryDbName,
      );
    }
    return all.first;
  }

  static TransactionSheetCategory? findByDbName(String dbName) {
    for (final c in all) {
      if (c.dbName == dbName) return c;
    }
    return null;
  }
}
