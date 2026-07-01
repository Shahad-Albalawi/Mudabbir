import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// Primary CTA — navy fill, iOS press scale, loading state.
class AppLoadingButton extends StatefulWidget {
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;
  final bool useCtaGreen;

  const AppLoadingButton({
    super.key,
    required this.isLoading,
    required this.label,
    this.onPressed,
    this.useCtaGreen = false,
  });

  @override
  State<AppLoadingButton> createState() => _AppLoadingButtonState();
}

class _AppLoadingButtonState extends State<AppLoadingButton> {
  bool _pressed = false;

  void _handleTap() {
    if (widget.isLoading || widget.onPressed == null) return;
    HapticService.medium();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: widget.label,
      button: true,
      child: GestureDetector(
        onTapDown: widget.isLoading ? null : (_) => setState(() => _pressed = true),
        onTapUp: widget.isLoading ? null : (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _handleTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          child: SizedBox(
            height: AppTouch.buttonHeight,
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.isLoading ? null : _handleTap,
              style: widget.useCtaGreen
                  ? FilledButton.styleFrom(backgroundColor: scheme.ctaGreen)
                  : null,
              child: AnimatedSwitcher(
                duration: AppMotion.fast,
                child: widget.isLoading
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
                        widget.label,
                        key: const ValueKey('label'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppTypographyScale.body,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
