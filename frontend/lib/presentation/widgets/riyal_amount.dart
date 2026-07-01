import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/currency_formatter.dart';
import 'package:mudabbir/presentation/resources/saudi_riyal_font.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Displays `[amount] [﷼]` with the official Saudi Riyal symbol font.
///
/// Falls back to plain "ريال" / "SAR" when the symbol font is unavailable.
class RiyalAmount extends StatelessWidget {
  const RiyalAmount(
    this.value, {
    super.key,
    this.fontSize,
    this.color,
    this.fontWeight = FontWeight.w400,
    this.symbolBold = false,
    this.decimals,
    this.textAlign,
    this.english,
    this.prefix,
    this.obscured = false,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  final num value;
  final double? fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final bool symbolBold;
  final int? decimals;
  final TextAlign? textAlign;
  final bool? english;
  final String? prefix;
  final bool obscured;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedColor = color ?? theme.colorScheme.onSurface;
    final size = fontSize ?? theme.textTheme.bodyMedium?.fontSize ?? 14;
    final useEn = english ?? AppStrings.isEnglishLocale;

    if (obscured) {
      return Text(
        '••••',
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: TextStyle(
          fontSize: size,
          fontWeight: fontWeight,
          color: resolvedColor,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
    }

    final numberText = AppCurrency.formatNumber(
      value,
      decimals: decimals ?? 0,
      english: useEn,
    );

    final numberStyle = TextStyle(
      fontSize: size,
      fontWeight: fontWeight,
      color: resolvedColor,
      height: 1.15,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final symbolSize = size * (symbolBold ? 0.92 : 0.85);
    final symbolWeight = symbolBold ? FontWeight.w700 : FontWeight.w400;

    if (!SaudiRiyalFont.isAvailable) {
      final fallback = useEn
          ? SaudiRiyalFont.fallbackLabelEn
          : SaudiRiyalFont.fallbackLabelAr;
      return Text(
        '${prefix ?? ''}$numberText $fallback',
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: numberStyle,
      );
    }

    return Text.rich(
      TextSpan(
        children: [
          if (prefix != null) TextSpan(text: prefix, style: numberStyle),
          TextSpan(text: numberText, style: numberStyle),
          const TextSpan(text: '\u00A0'),
          TextSpan(
            text: SaudiRiyalFont.symbol,
            style: TextStyle(
              fontFamily: SaudiRiyalFont.family,
              fontSize: symbolSize,
              fontWeight: symbolWeight,
              color: resolvedColor,
              height: 1.0,
            ),
          ),
        ],
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
