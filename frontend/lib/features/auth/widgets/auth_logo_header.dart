import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_colors.dart';
import 'package:mudabbir/presentation/resources/assets_manager.dart';

/// شعار مدبّر الأصلي داخل مربع Navy 60×60 بزوايا 18px.
class AuthLogoHeader extends StatelessWidget {
  const AuthLogoHeader({super.key});

  static const double boxSize = 60;
  static const double cornerRadius = 18;
  static const double markSize = 34;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: AppColors.navy1,
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      alignment: Alignment.center,
      child: Image.asset(
        ImageAssets.markWhite,
        width: markSize,
        height: markSize,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
