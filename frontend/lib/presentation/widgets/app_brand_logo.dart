import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/assets_manager.dart';

/// Official app mark — credit card on mint background (PNG).
class AppBrandLogo extends StatelessWidget {
  final double height;

  const AppBrandLogo({super.key, this.height = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ImageAssets.appLogo,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
