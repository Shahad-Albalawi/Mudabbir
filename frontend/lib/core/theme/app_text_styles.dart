import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_colors.dart';

/// Weight-based text helpers — IBM Plex Sans Arabic.
abstract final class AppText {
  AppText._();

  static const String fontFamily = 'IBMPlexSansArabic';
  static const String _font = fontFamily;

  static TextStyle bold(double size, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w700,
        fontSize: size,
        color: color ?? AppColors.text1,
        height: 1.4,
      );

  static TextStyle semiBold(double size, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w600,
        fontSize: size,
        color: color ?? AppColors.text1,
        height: 1.4,
      );

  static TextStyle medium(double size, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w500,
        fontSize: size,
        color: color ?? AppColors.text1,
        height: 1.4,
      );

  static TextStyle regular(double size, {Color? color}) => TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w400,
        fontSize: size,
        color: color ?? AppColors.text1,
        height: 1.4,
      );
}
