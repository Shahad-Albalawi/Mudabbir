import 'package:flutter/material.dart';

/// [BrandMarkTone.onDark]: splash / navy chrome — white wallet on navy tile.
/// [BrandMarkTone.onLight]: grouped surfaces — navy wallet on white tile.
enum BrandMarkTone { onDark, onLight }

/// Official Mudabbir wallet mark — always from bundled PNG assets (never Material icons).
class AppBrandLogo extends StatelessWidget {
  static const String assetOnLight = 'assets/images/app_logo.png';
  static const String assetOnDark = 'assets/images/app_logo_on_dark.png';

  final double height;
  final BrandMarkTone? tone;

  const AppBrandLogo({
    super.key,
    this.height = 32,
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
    final asset = resolved == BrandMarkTone.onDark ? assetOnDark : assetOnLight;

    return Semantics(
      label: 'Mudabbir',
      image: true,
      child: Image.asset(
        asset,
        height: height,
        width: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
