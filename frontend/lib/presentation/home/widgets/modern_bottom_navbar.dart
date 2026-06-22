import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// iOS-style tab bar — flat, Cupertino icons, brand primary active state.
class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final chromeFill = scheme.elevatedSurface.withValues(
      alpha: scheme.brightness == Brightness.dark ? 0.78 : 0.86,
    );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: chromeFill,
            border: Border(
              top: BorderSide(
                color: scheme.outline.withValues(
                  alpha: scheme.brightness == Brightness.dark ? 0.45 : 1,
                ),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: AppLayout.bottomNavHeight + (bottomInset > 0 ? 0 : 6),
              child: Row(
                children: [
                  _Tab(
                    icon: AppIcons.home,
                    activeIcon: AppIcons.homeFilled,
                    label: AppStrings.navHome,
                    index: 0,
                    currentIndex: currentIndex,
                    onTap: onTap,
                  ),
                  _Tab(
                    icon: AppIcons.statistics,
                    activeIcon: AppIcons.statisticsFilled,
                    label: AppStrings.navStatistics,
                    index: 1,
                    currentIndex: currentIndex,
                    onTap: onTap,
                  ),
                  _Tab(
                    icon: AppIcons.goals,
                    activeIcon: AppIcons.goalsFilled,
                    label: AppStrings.navGoals,
                    index: 2,
                    currentIndex: currentIndex,
                    onTap: onTap,
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

class _Tab extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = currentIndex == index;
    final activeColor = scheme.primary;
    final inactiveColor = scheme.textMuted;

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
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 24,
                color: isActive ? activeColor : inactiveColor,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppTypographyScale.caption,
                  fontWeight: FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AnimatedContainer(
                duration: AppMotion.fast,
                curve: AppMotion.standard,
                width: isActive ? 22 : 6,
                height: 4,
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor
                      : inactiveColor.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
