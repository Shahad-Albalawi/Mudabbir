import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/ios_style_constants.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/haptic_service.dart';

class ModernBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(IOSStyleConstants.navBarRadius),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height:
              IOSStyleConstants.navBarHeight +
              MediaQuery.of(context).padding.bottom,
          decoration: BoxDecoration(
            color: ColorManager.navBarFrosted,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context,
                icon: CupertinoIcons.house_fill,
                label: AppStrings.navHome,
                index: 0,
                isActive: currentIndex == 0,
              ),
              _buildNavItem(
                context,
                icon: CupertinoIcons.chart_bar_fill,
                label: AppStrings.navStatistics,
                index: 1,
                isActive: currentIndex == 1,
              ),
              _buildNavItem(
                context,
                icon: CupertinoIcons.flag_fill,
                label: AppStrings.navGoals,
                index: 2,
                isActive: currentIndex == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        HapticService.selection();
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: IOSStyleConstants.durationNormal,
        ),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? ColorManager.primaryWithOpacity20 : null,
          borderRadius: BorderRadius.circular(IOSStyleConstants.radiusLarge),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: ColorManager.primary.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isActive ? 1.15 : 1.0,
              duration: const Duration(
                milliseconds: IOSStyleConstants.durationNormal,
              ),
              curve: Curves.easeInOutCubic,
              child: Icon(
                icon,
                color: isActive ? ColorManager.primary : ColorManager.grey1,
                size: 24,
              ),
            ),
            SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              style: TextStyle(
                color: isActive ? ColorManager.primary : ColorManager.grey1,
                fontSize: isActive ? 12 : 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative Floating Action Button Style Bottom Nav
class FloatingBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.all(20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFloatingNavItem(
            context,
            icon: Icons.home_rounded,
            index: 0,
            isActive: currentIndex == 0,
          ),
          _buildFloatingNavItem(
            context,
            icon: Icons.bar_chart_rounded,
            index: 1,
            isActive: currentIndex == 1,
          ),
          _buildFloatingNavItem(
            context,
            icon: Icons.rocket_launch_rounded,
            index: 2,
            isActive: currentIndex == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavItem(
    BuildContext context, {
    required IconData icon,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : ColorManager.grey600,
          size: 24,
        ),
      ),
    );
  }
}

// Bubble Style Bottom Navigation
class BubbleBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BubbleBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background bubble indicator
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _getBubblePosition(context),
            top: 10,
            child: Container(
              width: MediaQuery.of(context).size.width / 3 - 20,
              height: 65,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(32.5),
              ),
            ),
          ),
          // Navigation items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBubbleNavItem(
                context,
                icon: Icons.home_rounded,
                label: AppStrings.navHome,
                index: 0,
                isActive: currentIndex == 0,
              ),
              _buildBubbleNavItem(
                context,
                icon: Icons.bar_chart_rounded,
                label: AppStrings.navStatistics,
                index: 1,
                isActive: currentIndex == 1,
              ),
              _buildBubbleNavItem(
                context,
                icon: Icons.rocket_launch_rounded,
                label: AppStrings.navGoals,
                index: 2,
                isActive: currentIndex == 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getBubblePosition(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / 3;
    return (currentIndex * itemWidth) + 10;
  }

  Widget _buildBubbleNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.8),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : ColorManager.grey600,
                size: 24,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? Theme.of(context).primaryColor
                    : ColorManager.grey600,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
