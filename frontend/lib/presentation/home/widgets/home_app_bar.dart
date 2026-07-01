import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

/// Transparent home header — greeting (start) + notifications (end).
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.userName,
    this.notificationBadgeCount = 0,
  });

  final String userName;
  final int notificationBadgeCount;

  static const double toolbarHeight = 72;

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  String _greeting() {
    if (userName.isEmpty) {
      return AppStrings.homeGreetingHello;
    }
    return AppStrings.homeGreetingNamed(userName);
  }

  String _monthLabel() {
    final locale = AppStrings.isEnglishLocale ? 'en' : 'ar';
    return DateFormat('MMMM yyyy', locale).format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: toolbarHeight,
      automaticallyImplyLeading: false,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _greeting(),
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 2),
          Text(
            _monthLabel(),
            style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
      actions: [
        Semantics(
          label: AppStrings.notificationsTitle,
          button: true,
          child: IconButton(
            onPressed: () {
              HapticService.light();
              context.push(AppRoutes.notifications);
            },
            icon: _NotificationBadge(count: notificationBadgeCount),
            tooltip: AppStrings.notificationsTitle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(AppIcons.notifications, size: 22, color: context.colors.textPrimary),
        if (count > 0)
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
                count > 9 ? '9+' : '$count',
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
