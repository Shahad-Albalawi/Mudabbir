import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/server_challenges/challenge_copy_helpers.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/utils/challenge_check_in_utils.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_badge_chip.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/utils/challenge_current_user.dart';

/// Leaderboard sorted by progress with medal icons and rank-change animation.
class ChallengeAnimatedLeaderboard extends StatefulWidget {
  const ChallengeAnimatedLeaderboard({
    super.key,
    required this.entries,
    this.maxItems = 8,
  });

  final List<LeaderboardEntryModel> entries;
  final int maxItems;

  @override
  State<ChallengeAnimatedLeaderboard> createState() =>
      _ChallengeAnimatedLeaderboardState();
}

class _ChallengeAnimatedLeaderboardState
    extends State<ChallengeAnimatedLeaderboard> {
  List<LeaderboardEntryModel> _previous = const [];

  List<LeaderboardEntryModel> _sorted(List<LeaderboardEntryModel> raw) {
    final copy = List<LeaderboardEntryModel>.from(raw)
      ..sort((a, b) {
        final byProgress = b.currentProgress.compareTo(a.currentProgress);
        if (byProgress != 0) return byProgress;
        return b.streakDays.compareTo(a.streakDays);
      });
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sorted(widget.entries).take(widget.maxItems).toList();
    final rankChanged = _previous.isNotEmpty &&
        sorted.isNotEmpty &&
        sorted.first.userId != _previous.first.userId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _previous = sorted);
    });

    if (sorted.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (var i = 0; i < sorted.length; i++)
          _AnimatedLeaderboardRow(
            key: ValueKey(sorted[i].userId),
            entry: sorted[i],
            rank: i + 1,
            animate: rankChanged || _previous.isEmpty,
            index: i,
          ),
      ],
    );
  }
}

class _AnimatedLeaderboardRow extends StatefulWidget {
  const _AnimatedLeaderboardRow({
    super.key,
    required this.entry,
    required this.rank,
    required this.animate,
    required this.index,
  });

  final LeaderboardEntryModel entry;
  final int rank;
  final bool animate;
  final int index;

  @override
  State<_AnimatedLeaderboardRow> createState() =>
      _AnimatedLeaderboardRowState();
}

class _AnimatedLeaderboardRowState extends State<_AnimatedLeaderboardRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    if (widget.animate) {
      Future<void>.delayed(Duration(milliseconds: widget.index * 60), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.t1Dark : AppColors.t1Light;
    final textSecondary = isDark ? AppColors.t2Dark : AppColors.t2Light;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
          child: Row(
            children: [
              _MedalBadge(rank: widget.rank),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.name,
                      style: AppTypography.bodyMedium(textPrimary).copyWith(
                        fontWeight: AppFontWeights.semiBold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${ServerChallengeStrings.formatAmount(widget.entry.currentProgress)} · ${ServerChallengeStrings.streakDays(widget.entry.streakDays)}',
                      style: AppTypography.bodySmall(textSecondary),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 4,
                children: [
                  if (widget.entry.badges.contains('streak_7'))
                    const ChallengeBadgeChip(badgeId: 'streak_7', compact: true),
                  if (widget.entry.badges.contains('streak_30'))
                    const ChallengeBadgeChip(
                      badgeId: 'streak_30',
                      compact: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedalBadge extends StatelessWidget {
  const _MedalBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final medal = ServerChallengeStrings.medalEmoji(rank);
    final isMedal = rank <= 3;

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isMedal
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Text(
        medal,
        style: TextStyle(
          fontSize: isMedal ? 18 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Horizontal strip — quick daily check-in for active challenges.
class ChallengeDailyCheckInStrip extends ConsumerWidget {
  const ChallengeDailyCheckInStrip({
    super.key,
    required this.challenges,
  });

  final List<ChallengeModel> challenges;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = <ChallengeModel>[];
    for (final c in challenges) {
      final me = ChallengeCurrentUser.participantIn(c);
      if (ChallengeCheckInUtils.canCheckIn(c, me)) pending.add(c);
    }

    if (pending.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(AppSpacing.md),
        color: AppColors.navy1.withValues(alpha: isDark ? 0.22 : 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ServerChallengeStrings.dailyCheckInStripTitle,
              style: AppTypography.titleSmall(
                isDark ? AppColors.t1Dark : AppColors.navy1,
              ).copyWith(fontWeight: AppFontWeights.bold),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...pending.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: FilledButton.icon(
                  onPressed: () {
                    HapticService.medium();
                    ref
                        .read(challengeOperationProvider.notifier)
                        .checkIn(challengeId: c.id);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy1,
                    foregroundColor: AppColors.textInverse,
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: Text(
                    ServerChallengeStrings.checkInForChallenge(c.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
