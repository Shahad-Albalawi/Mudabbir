import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_colors.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// [BrandMarkTone.onDark]: dark surfaces → white mark in navy container (`logo_dark.png`).
/// [BrandMarkTone.onLight]: light surfaces → navy mark in white container (`logo_light.png`).
enum BrandMarkTone { onDark, onLight }

/// Official مُدَبِّر brand icons in `assets/icons/`.
abstract final class MudabbirBrandAssets {
  /// Navy mark in white rounded container — light backgrounds.
  static const String onLight = 'assets/icons/logo_light.png';

  /// White mark in navy rounded container — dark backgrounds.
  static const String onDark = 'assets/icons/logo_dark.png';

  /// Raw marks (no container) — e.g. PDF / adaptive foreground.
  static const String markNavy = 'assets/icons/wallet_mark_navy.png';
  static const String markWhite = 'assets/icons/wallet_mark_white.png';

  static String forBrightness(bool isDark) =>
      isDark ? onDark : onLight;
}

/// Single logo image — prefer [MudabbirBrandHeader] for full centered layout.
class AppBrandLogo extends StatelessWidget {
  final double size;
  final BrandMarkTone? tone;

  const AppBrandLogo({
    super.key,
    this.size = 88,
    this.tone,
  });

  BrandMarkTone _resolve(BuildContext context) {
    if (tone != null) return tone!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? BrandMarkTone.onDark : BrandMarkTone.onLight;
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolve(context);
    final asset = resolved == BrandMarkTone.onDark
        ? MudabbirBrandAssets.onDark
        : MudabbirBrandAssets.onLight;

    return Semantics(
      label: AppStrings.title,
      image: true,
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

/// مدبر wordmark — always below the logo mark.
class MudabbirWordmark extends StatelessWidget {
  final double fontSize;
  final bool onDark;
  final TextAlign textAlign;

  const MudabbirWordmark({
    super.key,
    this.fontSize = 28,
    this.onDark = false,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final title = AppStrings.title;
    final isArabic = !AppStrings.isEnglishLocale;

    return Text(
      title,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: FontConstants.fontFamily,
        fontFamilyFallback: FontConstants.fontFamilyFallback,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: isArabic ? 0 : -0.5,
        color: onDark ? Colors.white : BrandPalette.navy,
        height: 1.15,
      ),
    );
  }
}

/// Centered brand block — logo centered, اسم التطبيق تحته.
class MudabbirBrandHeader extends StatelessWidget {
  final double logoSize;
  final double titleSize;
  final BrandMarkTone tone;
  final bool showTitle;
  final Widget? belowTitle;

  const MudabbirBrandHeader({
    super.key,
    this.logoSize = 96,
    this.titleSize = 28,
    this.tone = BrandMarkTone.onLight,
    this.showTitle = true,
    this.belowTitle,
  });

  const MudabbirBrandHeader.hero({
    super.key,
    this.logoSize = 104,
    this.titleSize = 32,
    this.showTitle = true,
    this.belowTitle,
  }) : tone = BrandMarkTone.onDark;

  const MudabbirBrandHeader.compact({
    super.key,
    this.logoSize = 80,
    this.titleSize = 24,
    this.showTitle = true,
    this.belowTitle,
    BrandMarkTone? tone,
  }) : tone = tone ?? BrandMarkTone.onLight;

  @override
  Widget build(BuildContext context) {
    final onDark = tone == BrandMarkTone.onDark;
    final asset =
        onDark ? MudabbirBrandAssets.onDark : MudabbirBrandAssets.onLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          asset,
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        if (showTitle) ...[
          SizedBox(height: logoSize * 0.18),
          MudabbirWordmark(
            fontSize: titleSize,
            onDark: onDark,
          ),
        ],
        if (belowTitle != null) ...[
          SizedBox(height: logoSize * 0.08),
          belowTitle!,
        ],
      ],
    );
  }
}
