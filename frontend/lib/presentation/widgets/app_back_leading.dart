import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/routing_service/app_navigation.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// iOS chevron back — 44×44 touch target, vertically centered in toolbar.
class AppBackLeading extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBackLeading({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.onSurface;

    return Semantics(
      button: true,
      label: AppStrings.navHome,
      child: IconButton(
        onPressed: () {
          HapticService.light();
          (onPressed ?? () => AppNavigation.goHome(context))();
        },
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 48, height: 44),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}
