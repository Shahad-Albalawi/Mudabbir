import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/widgets/app_brand_logo.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Minimal iOS launch screen — grouped canvas, app mark, no navy wash.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: scheme.pageBackground,
        body: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LaunchIcon(isDark: isDark),
                const SizedBox(height: 22),
                Text(
                  AppStrings.title,
                  style: TextStyle(
                    fontFamily: FontConstants.thmanyahFamily,
                    fontFamilyFallback: FontConstants.fontFamilyFallback,
                    fontSize: AppTypographyScale.pageTitle,
                    fontWeight: FontWeight.w700,
                    letterSpacing: AppTypographyScale.headlineTracking,
                    color: scheme.onSurface,
                    height: AppTypographyScale.headlineHeight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.splashTagline,
                  style: TextStyle(
                    fontFamily: FontConstants.thmanyahFamily,
                    fontFamilyFallback: FontConstants.fontFamilyFallback,
                    fontSize: AppTypographyScale.subhead,
                    fontWeight: FontWeight.w400,
                    color: scheme.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// iOS-style app icon tile on launch — white (or elevated) rounded square.
class _LaunchIcon extends StatelessWidget {
  final bool isDark;

  const _LaunchIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tileColor = isDark ? scheme.surface : Colors.white;

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: scheme.outline.withValues(alpha: isDark ? 0.35 : 0.12),
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      padding: const EdgeInsets.all(18),
      child: const AppBrandLogo(
        height: 52,
        tone: BrandMarkTone.onLight,
      ),
    );
  }
}
