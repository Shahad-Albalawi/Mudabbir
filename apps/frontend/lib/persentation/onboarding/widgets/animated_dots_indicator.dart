import 'package:mudabbir/persentation/resources/color_manager.dart';
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

class _AnimatedDotsIndicatorState extends State<AnimatedDotsIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.totalDots,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _animations = _controllers
        .map(
          (controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    // Animate current dot
    _controllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(AnimatedDotsIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reset all animations
      for (var controller in _controllers) {
        controller.reset();
      }
      // Animate current dot
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.totalDots,
        (index) => GestureDetector(
          onTap: () => widget.onDotTapped(index),
          child: AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              final isActive = index == widget.currentIndex;
              final animationValue = _animations[index].value;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isActive
                        ? ColorManager.primary
                        : ColorManager.grey300,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: ColorManager.primary.withValues(
                                alpha: 0.18 * animationValue,
                              ),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
