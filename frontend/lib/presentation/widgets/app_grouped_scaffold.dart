import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/modern_gradient_appbar.dart';

/// iOS grouped-table page shell — neutral canvas + flat navigation bar.
class AppGroupedScaffold extends StatelessWidget {
  final Widget body;
  final Widget? title;
  final String? titleText;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
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
    this.largeTitle = false,
    this.centerTitle = false,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.appBar,
    this.useAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    PreferredSizeWidget? bar = appBar;
    if (useAppBar && bar == null && (title != null || titleText != null)) {
      bar = ModernGradientAppBar(
        title: title ?? Text(titleText!),
        actions: actions,
        leading: leading,
        showBackButton: showBackButton,
        onBackPressed: onBackPressed,
        largeTitle: largeTitle,
        centerTitle: centerTitle,
      );
    }

    return Scaffold(
      backgroundColor: scheme.pageBackground,
      appBar: useAppBar ? bar : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: body,
    );
  }
}
