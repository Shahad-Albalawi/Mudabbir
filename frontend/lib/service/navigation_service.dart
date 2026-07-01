import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';

enum SnackbarType { success, error, warning, info }

/// Standard auto-dismiss duration for in-app feedback.
const Duration kAppSnackbarDuration = Duration(seconds: 5);

class _SnackbarConfig {
  final Color accentColor;
  final Color textColor;
  final IconData icon;

  const _SnackbarConfig({
    required this.accentColor,
    required this.textColor,
    required this.icon,
  });
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void showSnackbar({
    required String title,
    required String body,
    required SnackbarType type,
    Duration duration = kAppSnackbarDuration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = false,
    EdgeInsets? margin,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final scheme = Theme.of(context).colorScheme;
    final config = _getSnackbarConfig(scheme, type);
    final resolvedMargin = margin ?? _bottomMargin(context);

    final snackBar = SnackBar(
      duration: duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: resolvedMargin,
      dismissDirection: DismissDirection.down,
      content: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: scheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: AppElevation.cardShadow(
            isDark: scheme.brightness == Brightness.dark,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Icon(config.icon, color: config.accentColor, size: 24),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: config.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: TextStyle(
                        color: config.textColor.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action button
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onActionPressed,
                style: TextButton.styleFrom(
                  foregroundColor: config.textColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            // Close button
            if (showCloseButton) ...[
              const SizedBox(width: 4),
              IconButton(
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                icon: Icon(
                  Icons.close_rounded,
                  color: config.textColor.withValues(alpha: 0.8),
                  size: 18,
                ),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                splashRadius: 14,
              ),
            ],
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  EdgeInsets _bottomMargin(BuildContext context) {
    final inset = MediaQuery.of(context).padding.bottom;
    return EdgeInsets.fromLTRB(
      AppLayout.pageGutter,
      0,
      AppLayout.pageGutter,
      AppLayout.bottomNavHeight + inset + AppLayout.sectionGap,
    );
  }

  // Helper method to get configuration based on type
  _SnackbarConfig _getSnackbarConfig(ColorScheme scheme, SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          accentColor: scheme.success,
          textColor: scheme.onSurface,
          icon: Icons.check_circle_rounded,
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          accentColor: scheme.error,
          textColor: scheme.onSurface,
          icon: Icons.error_rounded,
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          accentColor: scheme.warning,
          textColor: scheme.onSurface,
          icon: Icons.warning_rounded,
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          accentColor: scheme.primary,
          textColor: scheme.onSurface,
          icon: Icons.info_rounded,
        );
    }
  }

  // Convenience methods
  void showSuccessSnackbar({
    required String title,
    required String body,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = false,
  }) {
    showSnackbar(
      title: title,
      body: body,
      type: SnackbarType.success,
      duration: duration ?? kAppSnackbarDuration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
    );
  }

  void showErrorSnackbar({
    required String title,
    required String body,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = false,
  }) {
    showSnackbar(
      title: title,
      body: body,
      type: SnackbarType.error,
      duration: duration ?? kAppSnackbarDuration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
    );
  }

  void showWarningSnackbar({
    required String title,
    required String body,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = false,
  }) {
    showSnackbar(
      title: title,
      body: body,
      type: SnackbarType.warning,
      duration: duration ?? kAppSnackbarDuration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
    );
  }

  void showInfoSnackbar({
    required String title,
    required String body,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = false,
  }) {
    showSnackbar(
      title: title,
      body: body,
      type: SnackbarType.info,
      duration: duration ?? kAppSnackbarDuration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      showCloseButton: showCloseButton,
    );
  }
}
