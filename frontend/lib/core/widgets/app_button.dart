export 'package:mudabbir/presentation/widgets/app_loading_button.dart'
    show AppLoadingButton;

import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';

/// Primary CTA — wraps [AppLoadingButton] with design-system defaults.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.useCtaGreen = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool useCtaGreen;

  @override
  Widget build(BuildContext context) {
    return AppLoadingButton(
      label: label,
      isLoading: isLoading,
      useCtaGreen: useCtaGreen,
      onPressed: onPressed,
    );
  }
}
