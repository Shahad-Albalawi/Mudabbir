import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_badge_chip.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';

class ChallengeLeaderboardCard extends ConsumerWidget {
  final int challengeId;

  const ChallengeLeaderboardCard({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final boardAsync = ref.watch(challengeLeaderboardProvider(challengeId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ServerChallengeStrings.leaderboardTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            boardAsync.when(
              loading: () => const Column(
                children: [
                  AppSkeletonBox(height: 44),
                  SizedBox(height: 10),
                  AppSkeletonBox(height: 44),
                  SizedBox(height: 10),
                  AppSkeletonBox(height: 44),
                ],
              ),
              error: (_, __) => IOSEmptyState(
                icon: Icons.leaderboard_outlined,
                title: ServerChallengeStrings.leaderboardEmpty,
                compact: true,
                animate: false,
              ),
              data: (board) {
                if (board.entries.isEmpty) {
                  return IOSEmptyState(
                    icon: Icons.leaderboard_outlined,
                    title: ServerChallengeStrings.leaderboardEmpty,
                    compact: true,
                    animate: false,
                  );
                }

                return Column(
                  children: board.entries
                      .take(5)
                      .map((e) => _entryTile(context, scheme, e))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryTile(
    BuildContext context,
    ColorScheme scheme,
    LeaderboardEntryModel entry,
  ) {
    final medalColor = entry.rank == 1
        ? scheme.warning
        : entry.rank == 2
            ? scheme.outline
            : entry.rank == 3
                ? const Color(0xFFCD7F32)
                : scheme.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: medalColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              ServerChallengeStrings.rankLabel(entry.rank),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: medalColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  ServerChallengeStrings.streakDays(entry.streakDays),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.textMuted,
                      ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 4,
            children: [
              if (entry.badges.contains('streak_7'))
                const ChallengeBadgeChip(badgeId: 'streak_7', compact: true),
              if (entry.badges.contains('streak_30'))
                const ChallengeBadgeChip(badgeId: 'streak_30', compact: true),
            ],
          ),
        ],
      ),
    );
  }
}
