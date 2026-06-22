import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/onboarding/onboarding_viewmodel.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/widgets/app_brand_logo.dart';

/// Single onboarding slide — iOS large title, calm body, minimal chrome.
class OnboardingPageWidget extends StatelessWidget {
  final SliderObject sliderObject;
  final bool isWelcome;

  const OnboardingPageWidget({
    super.key,
    required this.sliderObject,
    this.isWelcome = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.pageGutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          if (isWelcome)
            _WelcomeMark(isDark: isDark)
          else if (sliderObject.icon != null)
            _FeatureGlyph(icon: sliderObject.icon!, scheme: scheme),
          SizedBox(height: isWelcome ? 36 : 32),
          Text(
            sliderObject.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: AppTypographyScale.headlineTracking,
                  color: scheme.onSurface,
                  height: AppTypographyScale.headlineHeight,
                ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              sliderObject.subTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.textMuted,
                    height: 1.55,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

class _WelcomeMark extends StatelessWidget {
  final bool isDark;

  const _WelcomeMark({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: isDark ? scheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: scheme.outline.withValues(alpha: isDark ? 0.35 : 0.1),
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      padding: const EdgeInsets.all(24),
      child: const AppBrandLogo(
        height: 64,
        tone: BrandMarkTone.onLight,
      ),
    );
  }
}

class _FeatureGlyph extends StatelessWidget {
  final IconData icon;
  final ColorScheme scheme;

  const _FeatureGlyph({required this.icon, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: scheme.groupedFill,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 32,
        color: scheme.primary,
      ),
    );
  }
}
