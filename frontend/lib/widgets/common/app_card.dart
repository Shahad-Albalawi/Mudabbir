import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/widgets/ios_pressable.dart';

/// iOS-style grouped card — shadow in Light, border in Dark.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppLayout.pageGutter,
    ),
    this.borderRadius,
    this.onTap,
    this.color,
    this.gradient,
    this.bordered = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;

  /// Force border even in light mode (e.g. outlined cards).
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? RadiusTokens.lg;
    final resolvedPadding = padding ??
        const EdgeInsets.symmetric(
          horizontal: Spacing.xl,
          vertical: Spacing.xl,
        );

    final showBorder = isDark || bordered;
    final showShadow = !showBorder && gradient == null;

    final content = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.standard,
      margin: margin,
      padding: resolvedPadding,
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? Theme.of(context).cardTheme.color)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: showShadow ? AppShadows.card(context) : AppShadows.none,
        border: showBorder
            ? AppShadows.surfaceBorder(isDark: isDark)
            : null,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return IOSPressable(onTap: onTap!, child: content);
  }
}
