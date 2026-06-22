import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/widgets/ios_pressable.dart';

/// iOS grouped-table cell — white elevated surface on neutral canvas.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final bool bordered;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppLayout.pageGutter,
    ),
    this.onTap,
    this.color,
    this.gradient,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    final content = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? Theme.of(context).cardTheme.color) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        border: Border.all(
          color: scheme.outline.withValues(alpha: isDark ? 0.45 : 1),
          width: 0.5,
        ),
        boxShadow: AppElevation.cardShadow(isDark: isDark),
      ),
      child: child,
    );

    if (onTap == null) return content;

    return IOSPressable(onTap: onTap!, child: content);
  }
}
