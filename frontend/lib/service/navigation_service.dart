import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';

enum SnackbarType { success, error, warning, info }

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

  Future<dynamic> navigate(Widget widget) {
    return navigatorKey.currentState!.push(_animatedRoute(widget));
  }

  Future<dynamic> navigateReplacement(Widget widget) {
    return navigatorKey.currentState!.pushReplacement(_animatedRoute(widget));
  }

  @Deprecated('Use navigateReplacement')
  Future<dynamic> navigateReplacment(Widget widget) =>
      navigateReplacement(widget);

  Route _animatedRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Example: slide from right with fade
        const begin = Offset(1.0, 0.0); // start from right
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        final fadeTween = Tween<double>(begin: 0, end: 1);

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }

  void goBack() {
    navigatorKey.currentState!.pop();
  }

  Future<void> showDialog(/*BuildContext? context,*/ Widget widget) async {
    await showAdaptiveDialog(
      barrierDismissible: true,
      context: /*context ??*/ navigatorKey.currentContext!,
      builder: (context) => widget,
    );
  }

  void showSnackbar({
    required String title,
    required String body,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool showCloseButton = true,
    EdgeInsets? margin,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Hide any existing snackbars
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Get theme configuration
    final scheme = Theme.of(context).colorScheme;
    final config = _getSnackbarConfig(scheme, type);

    final snackBar = SnackBar(
      duration: duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: margin ?? const EdgeInsets.all(16),
      content: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: config.accentColor.withValues(alpha: 0.35),
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
  }) {
    showSnackbar(
      title: title,
      body: body,
      type: SnackbarType.success,
      duration: duration ?? const Duration(seconds: 3),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  void showErrorSnackbar({
    required String title,
    required String body,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    showSnackbar(
      title: title,
      body: body,
      type: SnackbarType.error,
      duration: duration ?? const Duration(seconds: 6),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  void showWarningSnackbar({
    required String title,
    required String body,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    showSnackbar(
      title: title,
      body: body,
      type: SnackbarType.warning,
      duration: duration ?? const Duration(seconds: 4),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  void showInfoSnackbar({
    required String title,
    required String body,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    showSnackbar(
      title: title,
      body: body,
      type: SnackbarType.info,
      duration: duration ?? const Duration(seconds: 4),
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }
}
