import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/widgets/app_animated_list_item.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// Unified empty state for lists, charts, and async views.
class IOSEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final bool compact;
  final bool animate;

  const IOSEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = '',
    this.buttonLabel,
    this.onPressed,
    this.iconColor,
    this.compact = false,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = iconColor ?? scheme.primary;
    final iconSize = compact ? 32.0 : 40.0;
    final circleSize = compact ? 72.0 : 88.0;

    final content = Semantics(
      container: true,
      label: subtitle.isEmpty ? title : '$title. $subtitle',
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 20 : AppLayout.pageGutter,
          vertical: compact ? 20 : 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: color.withValues(alpha: scheme.brightness == Brightness.dark ? 0.14 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: color,
              ),
            ),
            SizedBox(height: compact ? 16 : 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.textMuted,
                      height: 1.4,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonLabel != null && onPressed != null) ...[
              SizedBox(height: compact ? 16 : 24),
              AppLoadingButton(
                isLoading: false,
                label: buttonLabel!,
                onPressed: () {
                  HapticService.medium();
                  onPressed!();
                },
              ),
            ],
          ],
        ),
      ),
    );

    if (!animate) return content;
    return AppFadeIn(child: content);
  }
}

/// Alias for new code — same widget as [IOSEmptyState].
typedef AppEmptyState = IOSEmptyState;
