import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// Primary CTA — HIG 44pt touch target, navy fill, press feedback.
class AppLoadingButton extends StatelessWidget {
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;

  const AppLoadingButton({
    super.key,
    required this.isLoading,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      button: true,
      child: SizedBox(
        height: AppTouch.buttonHeight,
        width: double.infinity,
        child: FilledButton(
          onPressed: isLoading
              ? null
              : () {
                  HapticService.medium();
                  onPressed?.call();
                },
          style: FilledButton.styleFrom(
            minimumSize: AppTouch.buttonMinSize,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
          child: AnimatedSwitcher(
            duration: AppMotion.fast,
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            child: isLoading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : Text(
                    label,
                    key: const ValueKey('label'),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
          ),
        ),
      ),
    );
  }
}
