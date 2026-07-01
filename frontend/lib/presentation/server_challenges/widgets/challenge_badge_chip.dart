import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/server_challenges/challenge_copy_helpers.dart';

class ChallengeBadgeChip extends StatelessWidget {
  final String badgeId;
  final bool compact;

  const ChallengeBadgeChip({
    super.key,
    required this.badgeId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (icon, label, color) = switch (badgeId) {
      'streak_30' => (
          Icons.emoji_events,
          ServerChallengeStrings.badge30Title,
          scheme.warning,
        ),
      _ => (
          Icons.local_fire_department,
          ServerChallengeStrings.badge7Title,
          scheme.tertiary,
        ),
    };

    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 10,
          vertical: compact ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 12 : 14, color: color),
            if (!compact) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
