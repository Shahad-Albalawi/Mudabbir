import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom SVG icon for net-savings KPI (clock + currency motif).
class NetSavingsIcon extends StatelessWidget {
  const NetSavingsIcon({super.key, this.size = 14, this.color = Colors.white});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
  <path d="M12 2 C18 2 20 8 20 12 C20 18 14 22 8 20 C2 18 2 12 2 12"/>
  <polyline points="12,7 12,12 15,15"/>
  <circle cx="12" cy="12" r="1" fill="currentColor"/>
</svg>
''',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
