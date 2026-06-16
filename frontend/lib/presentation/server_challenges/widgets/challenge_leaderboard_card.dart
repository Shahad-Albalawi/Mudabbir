import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/resources/styles_manager.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_badge_chip.dart';

class ChallengeLeaderboardCard extends ConsumerWidget {
  final int challengeId;

  const ChallengeLeaderboardCard({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsync = ref.watch(challengeLeaderboardProvider(challengeId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ServerChallengeStrings.leaderboardTitle,
              style: getBoldStyle(
                fontSize: FontSize.s16,
                color: ColorManager.darkGrey,
              ),
            ),
            const SizedBox(height: 12),
            boardAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text(
                ServerChallengeStrings.leaderboardEmpty,
                style: getRegularStyle(
                  fontSize: FontSize.s14,
                  color: ColorManager.grey1,
                ),
              ),
              data: (board) {
                if (board.entries.isEmpty) {
                  return Text(
                    ServerChallengeStrings.leaderboardEmpty,
                    style: getRegularStyle(
                      fontSize: FontSize.s14,
                      color: ColorManager.grey1,
                    ),
                  );
                }

                return Column(
                  children: board.entries.take(5).map(_entryTile).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryTile(LeaderboardEntryModel entry) {
    final medalColor = entry.rank == 1
        ? const Color(0xFFFFD700)
        : entry.rank == 2
            ? const Color(0xFFC0C0C0)
            : entry.rank == 3
                ? const Color(0xFFCD7F32)
                : ColorManager.grey;

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
              style: getBoldStyle(fontSize: FontSize.s12, color: medalColor),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: getMediumStyle(
                    fontSize: FontSize.s14,
                    color: ColorManager.darkGrey,
                  ),
                ),
                Text(
                  ServerChallengeStrings.streakDays(entry.streakDays),
                  style: getRegularStyle(
                    fontSize: FontSize.s12,
                    color: ColorManager.grey1,
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
