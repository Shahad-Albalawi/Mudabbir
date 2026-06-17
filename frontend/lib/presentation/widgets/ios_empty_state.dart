import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';

/// iOS-style empty state — minimal, no bounce animation.
class IOSEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final Color? iconColor;

  const IOSEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = iconColor ?? scheme.textMuted;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 44, color: color.withValues(alpha: 0.85)),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: AppLayout.listRowHeight,
              child: CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                borderRadius: BorderRadius.circular(AppLayout.chipRadius),
                onPressed: onPressed,
                child: Text(buttonLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
