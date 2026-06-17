import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Flat app bar — iOS navigation bar style.
class ModernGradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double height;

  const ModernGradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.showBackButton = true,
    this.onBackPressed,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? scheme.surfaceContainerHighest : scheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: height,
      centerTitle: centerTitle,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Divider(
          height: 0.5,
          color: scheme.outline.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
      ),
      leading: leading ??
          (showBackButton && Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(CupertinoIcons.back, size: 22),
                  onPressed:
                      onBackPressed ?? () => Navigator.of(context).pop(),
                )
              : null),
      title: title,
      titleTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
