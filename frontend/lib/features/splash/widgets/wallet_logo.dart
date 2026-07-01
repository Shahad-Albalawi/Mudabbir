import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Brand wallet mark — SVG (`assets/icons/wallet_logo.svg`).
class WalletLogo extends StatelessWidget {
  const WalletLogo({
    super.key,
    required this.color,
    this.size = 80,
  });

  final Color color;
  final double size;

  static const assetPath = 'assets/icons/wallet_logo.svg';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      semanticsLabel: 'شعار مدبّر',
    );
  }
}
