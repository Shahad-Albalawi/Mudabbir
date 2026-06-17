import 'package:flutter/material.dart';

/// Simple theme-aware onboarding background.
class AnimatedBackground extends StatelessWidget {
  final int currentIndex;
  final int totalPages;

  const AnimatedBackground({
    super.key,
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}
