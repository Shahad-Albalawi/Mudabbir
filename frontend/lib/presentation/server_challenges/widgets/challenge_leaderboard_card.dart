import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/server_challenges/challenge_copy_helpers.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_animated_leaderboard.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';

class ChallengeLeaderboardCard extends ConsumerWidget {
  const ChallengeLeaderboardCard({super.key, required this.challengeId});

  final int challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsync = ref.watch(challengeLeaderboardProvider(challengeId));

    return AppCard(
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

              return ChallengeAnimatedLeaderboard(entries: board.entries);
            },
          ),
        ],
      ),
    );
  }
}
