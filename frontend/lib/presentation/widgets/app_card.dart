import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/widgets/ios_pressable.dart';

/// Flat, bordered surface — classic card style.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? color;
  final bool bordered;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppLayout.pageGutter,
    ),
    this.onTap,
    this.color,
    this.bordered = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final content = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        border: bordered
            ? Border.all(
                color: scheme.outline.withValues(
                  alpha: scheme.brightness == Brightness.dark ? 0.4 : 0.22,
                ),
              )
            : null,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return IOSPressable(onTap: onTap!, child: content);
  }
}
