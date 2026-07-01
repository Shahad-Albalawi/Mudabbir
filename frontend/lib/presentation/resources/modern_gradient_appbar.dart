import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/widgets/app_back_leading.dart';
import 'package:mudabbir/service/routing_service/app_navigation.dart';

/// iOS navigation bar — standard [AppBar] (safe-area correct), optional large title.
class ModernGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double height;
  final bool largeTitle;

  static const double _largeTitleSection = 48;

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

  VoidCallback _backAction(BuildContext context) =>
      onBackPressed ?? () => AppNavigation.goHome(context);

  PreferredSizeWidget? _hairline(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    return PreferredSize(
      preferredSize: const Size.fromHeight(0.5),
      child: Divider(
        height: 0.5,
        thickness: 0.5,
        color: scheme.outline.withValues(alpha: isDark ? 0.38 : 0.14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final back = showBackButton
        ? (leading ?? AppBackLeading(onPressed: _backAction(context)))
        : leading;

    return AppBar(
      backgroundColor: scheme.pageBackground,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: height,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leadingWidth: 48,
      leading: back,
      title: largeTitle
          ? const SizedBox.shrink()
          : Align(
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: AppTypographyScale.titleTracking,
                      color: scheme.onSurface,
                    ),
                child: title,
              ),
            ),
      actions: actions,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      bottom: largeTitle
          ? PreferredSize(
              preferredSize: const Size.fromHeight(_largeTitleSection),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.pageGutter,
                      0,
                      AppLayout.pageGutter,
                      AppSpacing.sm,
                    ),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: DefaultTextStyle.merge(
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppTypographyScale.display + 4,
                                  letterSpacing:
                                      AppTypographyScale.displayTracking,
                                  height: AppTypographyScale.displayHeight,
                                  color: scheme.onSurface,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        child: title,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _hairline(context),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        largeTitle ? height + _largeTitleSection : height + 0.5,
      );
}
