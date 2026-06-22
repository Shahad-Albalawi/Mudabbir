import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/widgets/app_brand_logo.dart';

/// Premium pre-auth layout — grouped canvas, large title, no heavy chrome.
class AuthFlowLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final ScrollController? scrollController;

  const AuthFlowLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.pageBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppLayout.pageGutter,
          AppSpacing.xl,
          AppLayout.pageGutter,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(
                    color: scheme.outline.withValues(
                      alpha: scheme.brightness == Brightness.dark ? 0.35 : 0.1,
                    ),
                    width: 0.5,
                  ),
                  boxShadow: AppElevation.cardShadow(
                    isDark: scheme.brightness == Brightness.dark,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: const AppBrandLogo(
                  height: 48,
                  tone: BrandMarkTone.onLight,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: AppTypographyScale.headlineTracking,
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.textMuted,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            child,
          ],
        ),
      ),
    );
  }
}
