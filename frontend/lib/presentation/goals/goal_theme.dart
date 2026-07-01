import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';

/// Per-goal accent color and emoji — keyed on name + type.
class GoalTheme {
  const GoalTheme({
    required this.color,
    required this.surface,
    required this.emoji,
  });

  final Color color;
  final Color surface;
  final String emoji;

  static GoalTheme forGoal(SavingsGoal goal) {
    final name = goal.name.toLowerCase();
    final type = goal.type.toLowerCase();

    if (_containsAny(name, ['سيارة', 'car', 'vehicle'])) {
      return const GoalTheme(
        color: AppColors.gold,
        surface: AppColors.goldS,
        emoji: '🚗',
      );
    }
    if (_containsAny(name, ['طوارئ', 'emergency', 'احتياط'])) {
      return const GoalTheme(
        color: AppColors.navy1,
        surface: AppColors.navySurface,
        emoji: '🛡️',
      );
    }
    if (_containsAny(name, ['منزل', 'بيت', 'house', 'home', 'سكن'])) {
      return const GoalTheme(
        color: AppColors.navy3,
        surface: AppColors.navySurface,
        emoji: '🏠',
      );
    }
    if (_containsAny(name, ['زواج', 'wedding', 'عرس'])) {
      return const GoalTheme(
        color: AppColors.chartPurple,
        surface: AppColors.goldS,
        emoji: '💍',
      );
    }
    if (_containsAny(name, ['سفر', 'travel', 'رحلة', 'vacation'])) {
      return const GoalTheme(
        color: AppColors.info,
        surface: AppColors.navySurface,
        emoji: '✈️',
      );
    }
    if (_containsAny(name, ['تعليم', 'education', 'جامعة', 'study'])) {
      return const GoalTheme(
        color: AppColors.navy4,
        surface: AppColors.navySurface,
        emoji: '🎓',
      );
    }

    if (_containsAny(type, ['investment', 'استثمار'])) {
      return const GoalTheme(
        color: AppColors.green,
        surface: AppColors.greenS,
        emoji: '📈',
      );
    }
    if (_containsAny(type, ['debt', 'دين'])) {
      return const GoalTheme(
        color: AppColors.orange,
        surface: AppColors.orangeSurface,
        emoji: '💳',
      );
    }
    if (_containsAny(type, ['saving', 'ادخار'])) {
      return const GoalTheme(
        color: AppColors.navy2,
        surface: AppColors.navySurface,
        emoji: '💰',
      );
    }

    final palette = [
      (AppColors.navy1, AppColors.navySurface, '🎯'),
      (AppColors.gold, AppColors.goldS, '⭐'),
      (AppColors.green, AppColors.greenS, '🌱'),
      (AppColors.chartPurple, AppColors.goldS, '🏆'),
    ];
    final i = goal.id.abs() % palette.length;
    final p = palette[i];
    return GoalTheme(color: p.$1, surface: p.$2, emoji: p.$3);
  }

  static bool _containsAny(String haystack, List<String> needles) {
    for (final n in needles) {
      if (haystack.contains(n.toLowerCase())) return true;
    }
    return false;
  }
}

/// Journey / progress accent — same family as card theme.
Color goalJourneyColor(SavingsGoal goal) => GoalTheme.forGoal(goal).color;
