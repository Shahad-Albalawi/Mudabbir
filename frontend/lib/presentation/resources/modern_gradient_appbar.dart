import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/ios_style_constants.dart';

/// iOS navigation bar — flat surface, optional large title (34pt bold).
class ModernGradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double height;
  final bool largeTitle;

  const ModernGradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.showBackButton = true,
    this.onBackPressed,
    this.height = 44,
    this.largeTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    if (largeTitle) {
      return _LargeTitleNavBar(
        title: title,
        actions: actions,
        leading: leading,
        showBackButton: showBackButton,
        onBackPressed: onBackPressed,
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: height,
      centerTitle: centerTitle,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Divider(
          height: 0.5,
          thickness: 0.5,
          color: scheme.outline.withValues(alpha: isDark ? 0.38 : 0.14),
        ),
      ),
      leading: leading ??
          (showBackButton && context.canPop()
              ? IconButton(
                  icon: const Icon(AppIcons.back, size: 22),
                  onPressed: onBackPressed ??
                      () {
                        if (context.canPop()) context.pop();
                      },
                )
              : null),
      title: DefaultTextStyle.merge(
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: AppTypographyScale.titleTracking,
              color: scheme.onSurface,
            ),
        child: title,
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(largeTitle ? IOSStyleConstants.largeTitleBarHeight : height);
}

class _LargeTitleNavBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const _LargeTitleNavBar({
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return Material(
      color: scheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                if (leading != null)
                  leading!
                else if (showBackButton && context.canPop())
                  IconButton(
                    icon: const Icon(AppIcons.back, size: 22),
                    onPressed: onBackPressed ??
                        () {
                          if (context.canPop()) context.pop();
                        },
                  )
                else
                  const SizedBox(width: 8),
                const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.smd,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: AppTypographyScale.largeTitle,
                      letterSpacing: AppTypographyScale.largeTitleTracking,
                      height: AppTypographyScale.largeTitleHeight,
                      color: scheme.onSurface,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                child: title,
              ),
            ),
          ),
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: scheme.outline.withValues(alpha: isDark ? 0.38 : 0.14),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(
        IOSStyleConstants.largeTitleBarHeight,
      );
}
