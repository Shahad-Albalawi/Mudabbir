import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/widgets/app_animated_list_item.dart';
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
    final color = iconColor ?? scheme.chromeIcon;
    final iconSize = compact ? 36.0 : 44.0;

    final content = Semantics(
      container: true,
      label: subtitle.isEmpty ? title : '$title. $subtitle',
      child: Padding(
        padding: EdgeInsets.all(compact ? 20 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 72 : 92,
              height: compact ? 72 : 92,
              padding: EdgeInsets.all(compact ? 14 : 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.18),
                    color.withValues(alpha: 0.06),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.outline.withValues(
                    alpha: scheme.brightness == Brightness.dark ? 0.45 : 1,
                  ),
                  width: 0.5,
                ),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: color.withValues(alpha: 0.9),
              ),
            ),
            SizedBox(height: compact ? 16 : 20),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: scheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: scheme.textMuted,
                      height: 1.35,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonLabel != null && onPressed != null) ...[
              SizedBox(height: compact ? 16 : 24),
              SizedBox(
                height: AppTouch.buttonHeight,
                child: FilledButton(
                  onPressed: () {
                    HapticService.medium();
                    onPressed!();
                  },
                  child: Text(buttonLabel!),
                ),
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
