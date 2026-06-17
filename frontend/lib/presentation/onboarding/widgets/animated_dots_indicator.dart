import 'package:flutter/material.dart';

class AnimatedDotsIndicator extends StatefulWidget {
  final int currentIndex;
  final int totalDots;
  final Function(int) onDotTapped;

  const AnimatedDotsIndicator({
    super.key,
    required this.currentIndex,
    required this.totalDots,
    required this.onDotTapped,
  });

  @override
  State<AnimatedDotsIndicator> createState() => _AnimatedDotsIndicatorState();
}

class _AnimatedDotsIndicatorState extends State<AnimatedDotsIndicator> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.totalDots,
        (index) => GestureDetector(
          onTap: () => widget.onDotTapped(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: index == widget.currentIndex ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: index == widget.currentIndex
                  ? scheme.primary
                  : scheme.outline.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}
