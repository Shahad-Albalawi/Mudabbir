import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_colors.dart';

/// iOS UIPageControl-style dots — same size, subtle inactive fill.
class AnimatedDotsIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalDots;
  final ValueChanged<int> onDotTapped;

  const AnimatedDotsIndicator({
    super.key,
    required this.currentIndex,
    required this.totalDots,
    required this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final active = isDark ? DarkAppColors.textPrimary : BrandPalette.brandPrimary;
    final inactive = scheme.outline.withValues(alpha: isDark ? 0.45 : 0.35);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDots, (index) {
        final selected = index == currentIndex;
        return GestureDetector(
          onTap: () => onDotTapped(index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? active : inactive,
              ),
            ),
          ),
        );
      }),
    );
  }
}
