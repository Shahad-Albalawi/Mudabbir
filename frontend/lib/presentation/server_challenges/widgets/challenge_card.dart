import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/server_challenges/challenge_copy_helpers.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/utils/challenge_check_in_utils.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_badge_chip.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_progress_ring.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:mudabbir/utils/challenge_current_user.dart';

class ChallengeCard extends ConsumerWidget {
  const ChallengeCard({super.key, required this.challenge});

  final ChallengeModel challenge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final progressPercent = challenge.displayProgressPercent;
    final ringColor = challengeProgressColor(progressPercent / 100);
    final me = ChallengeCurrentUser.participantIn(challenge);
    final canCheckIn = ChallengeCheckInUtils.canCheckIn(challenge, me);

    return Semantics(
      label: challenge.name,
      button: true,
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        onTap: () => context.push(AppRoutes.challengeDetail(challenge.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildHeader(context, scheme)),
                const SizedBox(width: 12),
                ChallengeProgressRing(
                  percent: progressPercent,
                  color: ringColor,
                  size: 68,
                ),
              ],
            ),
            if (challenge.description != null &&
                challenge.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                challenge.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.textMuted,
                      height: 1.35,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            _buildAmountRow(scheme),
            const SizedBox(height: 8),
            _buildDateInfo(context, scheme),
            if (challenge.badges.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: [
                  if (challenge.badges.contains('streak_7'))
                    const ChallengeBadgeChip(badgeId: 'streak_7', compact: true),
                  if (challenge.badges.contains('streak_30'))
                    const ChallengeBadgeChip(
                      badgeId: 'streak_30',
                      compact: true,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            _buildFooter(scheme),
            if (canCheckIn) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    HapticService.medium();
                    ref
                        .read(challengeOperationProvider.notifier)
                        .checkIn(challengeId: challenge.id);
                  },
                  icon: const Icon(CupertinoIcons.flame_fill, size: 18),
                  label: Text(ServerChallengeStrings.checkInButton),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          challenge.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        _buildStatusBadge(scheme),
      ],
    );
  }

  Widget _buildStatusBadge(ColorScheme scheme) {
    final (color, icon, text) = _statusInfo(scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _statusInfo(ColorScheme scheme) {
    switch (challenge.status) {
      case ChallengeStatus.completed:
        return (
          scheme.dataGreen,
          CupertinoIcons.checkmark_seal_fill,
          ServerChallengeStrings.cardCompleted,
        );
      case ChallengeStatus.expired:
        return (
          scheme.error,
          CupertinoIcons.xmark_circle_fill,
          ServerChallengeStrings.cardExpired,
        );
      case ChallengeStatus.active:
        return (
          scheme.primary,
          CupertinoIcons.flame_fill,
          ServerChallengeStrings.cardActive,
        );
      case ChallengeStatus.upcoming:
        return (
          scheme.warning,
          CupertinoIcons.time,
          ServerChallengeStrings.cardUpcoming,
        );
    }
  }

  Widget _buildDateInfo(BuildContext context, ColorScheme scheme) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Row(
      children: [
        Icon(AppIcons.calendar, size: 16, color: scheme.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${dateFormat.format(challenge.startDate)} - ${dateFormat.format(challenge.endDate)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.textMuted,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(ColorScheme scheme) {
    return Row(
      children: [
        Icon(AppIcons.wallet, size: 16, color: scheme.chromeIcon),
        const SizedBox(width: 8),
        Text(
          ServerChallengeStrings.goalAmount(challenge.targetAmount),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: scheme.dataGreen,
          ),
        ),
        const Spacer(),
        if (challenge.isActive)
          Text(
            ServerChallengeStrings.daysRemaining(challenge.daysRemaining),
            style: TextStyle(fontSize: 12, color: scheme.textMuted),
          ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme scheme) {
    final count = challenge.acceptedParticipants.length;
    if (count == 0) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(CupertinoIcons.person_2, size: 16, color: scheme.textMuted),
        const SizedBox(width: 6),
        Text(
          ServerChallengeStrings.participantCount(count),
          style: TextStyle(fontSize: 12, color: scheme.textMuted),
        ),
        const Spacer(),
        Text(
          ServerChallengeStrings.formatAmount(challenge.currentProgress),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }
}
