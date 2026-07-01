import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

/// شريط علوي — تحية يمين، إشعارات وإعدادات يسار (بدون اسم التطبيق).
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({
    super.key,
    required this.userName,
    this.notificationBadgeCount = 0,
  });

  final String userName;
  final int notificationBadgeCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t2 = colors.textTertiary;
    final displayName = userName.trim().isEmpty ? 'ضيف' : userName.trim();
    final initial = displayName.characters.first;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.sm,
          Spacing.lg,
          Spacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [AppColors.navyDark, const Color(0xFF6B93ED)]
                          : const [AppColors.navy1, AppColors.navy3],
                    ),
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'أهلاً، $displayName 👋',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'إليك ملخص مالك اليوم',
                        style: TextStyle(fontSize: 11, color: t2),
                      ),
                    ],
                  ),
                ),
              ],
              ),
            ),
            _CircleIconButton(
              icon: AppIcons.notifications,
              badgeCount: notificationBadgeCount,
              onTap: () {
                HapticService.light();
                context.push(AppRoutes.notifications);
              },
              tooltip: AppStrings.notificationsTitle,
            ),
            const SizedBox(width: 8),
            _CircleIconButton(
              icon: AppIcons.settings,
              onTap: () {
                HapticService.light();
                context.push(AppRoutes.settings);
              },
              tooltip: AppStrings.settingsOpenLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final border = colors.border;
    final iconColor = colors.textPrimary;

    return Semantics(
      label: tooltip,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: border, width: 1),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 18, color: iconColor),
                if (badgeCount > 0)
                  Positioned(
                    top: 6,
                    right: 8,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
