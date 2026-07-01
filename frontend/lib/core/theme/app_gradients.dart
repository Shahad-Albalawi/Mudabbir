import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_colors.dart';

/// مدبّر — brand gradients for hero cards and semantic surfaces.
abstract final class AppGradients {
  AppGradients._();

  static const LinearGradient primaryCard = LinearGradient(
    colors: [AppColors.navy, AppColors.navyMedium, AppColors.navyLight],
    stops: [0.0, 0.55, 1.0],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static LinearGradient primaryCardFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? primaryCardDark : primaryCard;
  }

  static const LinearGradient primaryCardDark = LinearGradient(
    colors: [Color(0xFF2F5BB8), AppColors.navyDark],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient splash = LinearGradient(
    colors: [
      AppColors.bgDark,
      AppColors.s1Dark,
      AppColors.navyDark,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF0F6B3F), AppColors.green],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFA82020), AppColors.red],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFF8A5A00), AppColors.gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
