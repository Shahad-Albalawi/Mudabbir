import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/behavioral_strings.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/score_ring_widget.dart';

/// Behavioral score summary — used on analysis & statistics screens.
class BehavioralScoreCard extends StatelessWidget {
  final int score;
  final String rating;
  final String summary;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool compact;

  const BehavioralScoreCard({
    super.key,
    required this.score,
    required this.rating,
    required this.summary,
    required this.accentColor,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ringSize = compact ? 96.0 : 112.0;

    return AppCard(
      margin: EdgeInsets.zero,
      onTap: onTap,
      color: scheme.brightness == Brightness.light
          ? scheme.homeBannerFill.withValues(alpha: 0.35)
          : scheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            BehavioralStrings.behavioralScoreTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.textOnCard,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            BehavioralStrings.behavioralScoreSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.textMuted,
              height: 1.35,
            ),
          ),
          SizedBox(height: compact ? 12 : 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScoreRingWidget(
                score: score,
                color: accentColor,
                size: ringSize,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.textMuted,
                        height: 1.45,
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            BehavioralStrings.viewDetailsLabel,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                              color: scheme.homeGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: scheme.homeGreen,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
