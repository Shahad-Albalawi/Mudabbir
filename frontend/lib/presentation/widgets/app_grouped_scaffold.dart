import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/modern_gradient_appbar.dart';
import 'package:mudabbir/presentation/widgets/section_title_text.dart';
import 'package:mudabbir/service/routing_service/app_navigation.dart';

/// iOS grouped-table page shell — neutral canvas + flat navigation bar.
class AppGroupedScaffold extends StatelessWidget {
  final Widget body;
  final Widget? title;
  final String? titleText;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final String? backFallbackRoute;
  final bool largeTitle;
  final bool centerTitle;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final PreferredSizeWidget? appBar;
  final bool useAppBar;

  const AppGroupedScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleText,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.backFallbackRoute,
    this.largeTitle = false,
    this.centerTitle = false,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.appBar,
    this.useAppBar = true,
  });

  VoidCallback _resolveBackHandler(BuildContext context) {
    if (onBackPressed != null) return onBackPressed!;
    final fallback = backFallbackRoute;
    if (fallback != null) {
      return () => AppNavigation.goBackOr(context, fallback);
    }
    return () => AppNavigation.goHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final handleBack = _resolveBackHandler(context);

    PreferredSizeWidget? bar = appBar;
    final hasTitle = title != null || (titleText != null && titleText!.isNotEmpty);

    if (useAppBar && bar == null && (hasTitle || showBackButton)) {
      bar = ModernGradientAppBar(
        title: title ??
            SectionTitleText(
              titleText ?? '',
              fullWidth: largeTitle,
            ),
        actions: actions,
        leading: leading,
        showBackButton: showBackButton,
        onBackPressed: handleBack,
        largeTitle: largeTitle,
        centerTitle: centerTitle,
      );
    }

    final scaffold = Scaffold(
      backgroundColor: scheme.pageBackground,
      appBar: useAppBar ? bar : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: body,
    );

    if (!showBackButton) return scaffold;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) handleBack();
      },
      child: scaffold,
    );
  }
}
