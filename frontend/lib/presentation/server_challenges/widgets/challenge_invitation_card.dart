import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/server_challenges/challenge_copy_helpers.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_state.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// Pending invitation card — accept / decline actions.
class ChallengeInvitationCard extends ConsumerWidget {
  const ChallengeInvitationCard({
    super.key,
    required this.challenge,
    this.onResponded,
  });

  final ChallengeModel challenge;
  final VoidCallback? onResponded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy');
    final operationState = ref.watch(challengeOperationProvider);
    final isLoading = operationState is ChallengeOperationLoading;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: scheme.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 14, color: scheme.warning),
                    const SizedBox(width: 4),
                    Text(
                      ServerChallengeStrings.pendingStatus,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow(context, Icons.person_outline,
              ServerChallengeStrings.fromCreator(challenge.creator.name)),
          const SizedBox(height: 8),
          _infoRow(context, Icons.payments_outlined,
              ServerChallengeStrings.totalAmount(challenge.amount)),
          const SizedBox(height: 8),
          _infoRow(
            context,
            Icons.calendar_today_outlined,
            '${dateFormat.format(challenge.startDate)} - ${dateFormat.format(challenge.endDate)}',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          HapticService.light();
                          ref
                              .read(challengeOperationProvider.notifier)
                              .respondToInvitation(
                                challengeId: challenge.id,
                                accept: false,
                              )
                              .then((_) => onResponded?.call());
                        },
                  icon: const Icon(Icons.close_rounded),
                  label: Text(ServerChallengeStrings.decline),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          HapticService.medium();
                          ref
                              .read(challengeOperationProvider.notifier)
                              .respondToInvitation(
                                challengeId: challenge.id,
                                accept: true,
                              )
                              .then((_) => onResponded?.call());
                        },
                  icon: const Icon(Icons.check_rounded),
                  label: Text(ServerChallengeStrings.accept),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface,
                ),
          ),
        ),
      ],
    );
  }
}
