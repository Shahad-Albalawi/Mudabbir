import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/app_colors.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:mudabbir/presentation/widgets/section_title_text.dart';

/// Shared shell app bar — settings (visual left), title, notifications (visual right).
class ShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShellAppBar({
    super.key,
    required this.title,
    this.notificationBadgeCount = 0,
  });

  final String title;
  final int notificationBadgeCount;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      leading: Semantics(
        label: AppStrings.notificationsTitle,
        button: true,
        child: IconButton(
          onPressed: () {
            HapticService.light();
            context.push(AppRoutes.notifications);
          },
          icon: _BadgedIcon(
            icon: const Icon(AppIcons.notifications, size: 22),
            count: notificationBadgeCount,
          ),
          tooltip: AppStrings.notificationsTitle,
        ),
      ),
      title: SectionTitleText(
        title,
        fullWidth: false,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      actions: [
        Semantics(
          label: AppStrings.settingsOpenLabel,
          button: true,
          child: IconButton(
            onPressed: () {
              HapticService.light();
              context.push(AppRoutes.settings);
            },
            icon: const Icon(AppIcons.settings, size: 22),
            tooltip: AppStrings.settingsOpenLabel,
          ),
        ),
      ],
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({required this.icon, required this.count});

  final Widget icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return icon;

    final display = count > 9 ? '9+' : '$count';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        PositionedDirectional(
          top: -2,
          end: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            decoration: BoxDecoration(
              color: context.colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              display,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    height: 1.1,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
