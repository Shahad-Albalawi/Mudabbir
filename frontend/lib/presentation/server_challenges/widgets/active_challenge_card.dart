import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/server_challenges/challenge_copy_helpers.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/utils/challenge_check_in_utils.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:mudabbir/utils/challenge_current_user.dart';

/// Calm bordered card for active challenges — log, streak, progress bar.
class ActiveChallengeCard extends ConsumerWidget {
  const ActiveChallengeCard({super.key, required this.challenge});

  final ChallengeModel challenge;

  IconData _iconFor(ChallengeModel challenge) {
    final name = challenge.name.toLowerCase();
    if (name.contains('قهو') || name.contains('coffee')) {
      return Icons.local_cafe_outlined;
    }
    if (name.contains('ادخار') ||
        name.contains('save') ||
        name.contains('توفير')) {
      return Icons.savings_outlined;
    }
    if (name.contains('مصروف') || name.contains('spend')) {
      return Icons.money_off_csred_outlined;
    }
    if (name.contains('مشترك') ||
        name.contains('group') ||
        name.contains('فريق')) {
      return Icons.groups_outlined;
    }
    return Icons.flag_outlined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final me = ChallengeCurrentUser.participantIn(challenge);
    final canLog = ChallengeCheckInUtils.canCheckIn(challenge, me);
    final progress = challenge.activeLogProgressPercent;
    final subtitle = challenge.activeCardSubtitle();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.border, width: 0.5),
        boxShadow: AppShadows.sm(isDark: isDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () => context.push(AppRoutes.challengeDetail(challenge.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconFor(challenge),
                        size: 22,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _ActiveChip(),
                        const SizedBox(height: 8),
                        _LogButton(
                          enabled: canLog,
                          onPressed: () {
                            HapticService.light();
                            ref
                                .read(challengeOperationProvider.notifier)
                                .checkIn(challengeId: challenge.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 6,
                    backgroundColor: colors.primarySurface,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    '$progress%',
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.greenSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.green.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        ServerChallengeStrings.cardActive,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colors.green,
        ),
      ),
    );
  }
}

class _LogButton extends StatelessWidget {
  const _LogButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 30,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(
            color: colors.primary.withValues(alpha: enabled ? 0.45 : 0.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          ServerChallengeStrings.logButton,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
