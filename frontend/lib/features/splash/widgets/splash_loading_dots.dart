import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_colors.dart';

/// ثلاث نقاط تحميل بنبضة متدرجة (دورة 1.2ث، تأخير 0.18ث بين النقاط).
class SplashLoadingDots extends StatefulWidget {
  const SplashLoadingDots({
    super.key,
    this.color = AppColors.navy1,
    this.dotSize = 8,
    this.gap = 10,
  });

  final Color color;
  final double dotSize;
  final double gap;

  static const cycle = Duration(milliseconds: 1200);
  static const stagger = Duration(milliseconds: 180);

  @override
  State<SplashLoadingDots> createState() => _SplashLoadingDotsState();
}

class _SplashLoadingDotsState extends State<SplashLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: SplashLoadingDots.cycle)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _phaseFor(int index) {
    final staggerFraction =
        SplashLoadingDots.stagger.inMilliseconds / SplashLoadingDots.cycle.inMilliseconds;
    return (_controller.value + index * staggerFraction) % 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = _phaseFor(index);
            final wave = (math.sin(phase * 2 * math.pi) + 1) / 2;
            final opacity = 0.28 + wave * 0.72;
            final scale = 0.82 + wave * 0.18;

            return Padding(
              padding: EdgeInsetsDirectional.only(
                start: index == 0 ? 0 : widget.gap / 2,
                end: index == 2 ? 0 : widget.gap / 2,
              ),
              child: Transform.scale(
                scale: scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.color.withValues(alpha: opacity),
                        widget.color.withValues(alpha: opacity * 0.45),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: opacity * 0.35),
                        blurRadius: 6 * wave,
                        spreadRadius: 0.5 * wave,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: widget.dotSize,
                    height: widget.dotSize,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
