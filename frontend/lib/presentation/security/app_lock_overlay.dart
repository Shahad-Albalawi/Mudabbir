import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_brand_logo.dart';
import 'package:mudabbir/service/security/biometric_lock_provider.dart';

/// Full-screen gate shown when biometric lock is enabled and the app is locked.
class AppLockOverlay extends ConsumerWidget {
  const AppLockOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(biometricLockProvider);
    if (!lockState.loaded || !lockState.locked) {
      return child;
    }

    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Material(
            color: colors.background,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppBrandLogo(size: 72),
                    const SizedBox(height: 32),
                    Icon(
                      Icons.fingerprint_rounded,
                      size: 64,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.biometricLockTitle,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.biometricLockSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: AuthSubmitButtonHeight.height,
                      child: FilledButton(
                        onPressed: () =>
                            ref.read(biometricLockProvider.notifier).unlock(),
                        child: Text(AppStrings.biometricUnlockButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shared submit button height for visual consistency with auth screens.
abstract final class AuthSubmitButtonHeight {
  static const double height = 52;
}
