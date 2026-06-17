import 'package:flutter/material.dart';

/// Donut progress ring with a clear center for the score (no overlap with the arc).
class ScoreRingWidget extends StatelessWidget {
  final int score;
  final Color color;
  final double size;
  final double strokeWidth;

  const ScoreRingWidget({
    super.key,
    required this.score,
    required this.color,
    this.size = 108,
    this.strokeWidth = 9,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final innerSize = size - (strokeWidth * 2.6);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: (score.clamp(0, 100)) / 100,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              backgroundColor: scheme.outline.withValues(alpha: 0.18),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surface,
            ),
            alignment: Alignment.center,
            child: Text(
              '$score',
              style: TextStyle(
                fontSize: size * 0.26,
                fontWeight: FontWeight.w700,
                color: color,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
