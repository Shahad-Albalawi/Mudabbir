import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_colors.dart';

class RiyalText extends StatelessWidget {
  const RiyalText({
    super.key,
    required this.amount,
    this.fontSize = 14,
    this.color,
    this.bold = false,
  });

  final double amount;
  final double fontSize;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (Theme.of(context).brightness == Brightness.dark
            ? AppColors.text1Dark
            : AppColors.text1);
    final formatted = _formatAmount(amount);
    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: effectiveColor,
        ),
        children: [
          TextSpan(text: formatted),
          const TextSpan(text: ' '),
          // رمز الريال الرسمي
          TextSpan(
            text: '\u{20C1}', // U+20C1 — رمز الريال السعودي الرسمي
            style: TextStyle(
              fontFamily: 'SaudiRiyal',
              fontSize: fontSize * 0.85,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double v) {
    // تنسيق بالأرقام العربية
    final s = v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 2);
    final parts = s.split('.');
    final intPart = _addCommas(parts[0]);
    return parts.length > 1 && parts[1] != '00'
        ? '$intPart.${parts[1]}'
        : intPart;
  }

  String _addCommas(String s) {
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write('٬');
      result.write(s[i]);
    }
    // تحويل للأرقام العربية
    return result
        .toString()
        .replaceAll('0', '٠')
        .replaceAll('1', '١')
        .replaceAll('2', '٢')
        .replaceAll('3', '٣')
        .replaceAll('4', '٤')
        .replaceAll('5', '٥')
        .replaceAll('6', '٦')
        .replaceAll('7', '٧')
        .replaceAll('8', '٨')
        .replaceAll('9', '٩');
  }
}
