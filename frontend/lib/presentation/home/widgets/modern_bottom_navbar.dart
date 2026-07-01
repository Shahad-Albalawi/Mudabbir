import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_colors.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// iOS-style tab bar with center FAB for adding transactions.
class ModernBottomNavBar extends StatelessWidget {
  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onFabPressed,
  });

  /// Logical tab index: 0 home, 1 statistics, 2 goals, 3 challenges.
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onFabPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chromeFill = colors.background.withValues(alpha: isDark ? 0.92 : 0.94);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: chromeFill,
            border: Border(
              top: BorderSide(
                color: colors.border.withValues(alpha: isDark ? 0.45 : 1),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 56,
              child: Row(
                children: [
                  _Tab(
                    icon: AppIcons.home,
                    activeIcon: AppIcons.homeFilled,
                    label: AppStrings.navHome,
                    index: 0,
                    currentIndex: currentIndex,
                    onTap: onTabSelected,
                  ),
                  _Tab(
                    icon: AppIcons.statistics,
                    activeIcon: AppIcons.statisticsFilled,
                    label: AppStrings.navStatistics,
                    index: 1,
                    currentIndex: currentIndex,
                    onTap: onTabSelected,
                  ),
                  _CenterFab(onPressed: onFabPressed),
                  _Tab(
                    icon: AppIcons.goals,
                    activeIcon: AppIcons.goalsFilled,
                    label: AppStrings.navGoals,
                    index: 2,
                    currentIndex: currentIndex,
                    onTap: onTabSelected,
                  ),
                  _Tab(
                    icon: AppIcons.trophy,
                    activeIcon: AppIcons.trophyFilled,
                    label: AppStrings.navChallenges,
                    index: 3,
                    currentIndex: currentIndex,
                    onTap: onTabSelected,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterFab extends StatelessWidget {
  const _CenterFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 72,
      child: Transform.translate(
        offset: const Offset(0, -14),
        child: Semantics(
          label: AppStrings.addTransactionTitle,
          button: true,
          child: Material(
            elevation: 0,
            color: colors.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                HapticService.medium();
                onPressed();
              },
              child: const SizedBox(
                width: 52,
                height: 52,
                child: Icon(
                  AppIcons.add,
                  color: AppColors.textInverse,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isActive = currentIndex == index;

    return Expanded(
      child: Semantics(
        label: label,
        selected: isActive,
        button: true,
        child: InkWell(
          onTap: () {
            HapticService.selection();
            onTap(index);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? colors.primary : colors.textTertiary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: AppTypographyScale.caption,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? colors.primary : colors.textTertiary,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
