import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/server_challenges/challenge_copy_helpers.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_badge_chip.dart';

class ParticipantItem extends StatelessWidget {
  final ParticipantModel participant;
  final bool isCreator;
  final VoidCallback? onRemove;

  const ParticipantItem({
    super.key,
    required this.participant,
    this.isCreator = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      label: participant.name,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _backgroundColor(scheme),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor(scheme)),
        ),
        child: Row(
          children: [
            _buildAvatar(context, scheme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          participant.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCreator)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            ServerChallengeStrings.roleCreator,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: scheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    participant.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.textMuted,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusBadge(context, scheme),
                      const SizedBox(width: 8),
                      if (participant.isAccepted && participant.streakDays > 0) ...[
                        Icon(Icons.local_fire_department,
                            size: 12, color: scheme.tertiary),
                        const SizedBox(width: 2),
                        Text(
                          '${participant.streakDays}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.tertiary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (participant.targetAmount != null) ...[
                        Icon(Icons.flag, size: 12, color: scheme.chromeIcon),
                        const SizedBox(width: 4),
                        Text(
                          ServerChallengeStrings.formatAmount(
                            participant.targetAmount!,
                          ),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                      const Spacer(),
                      if (participant.isAccepted)
                        Icon(
                          participant.achieved
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 16,
                          color: participant.achieved
                              ? scheme.success
                              : scheme.textMuted,
                        ),
                    ],
                  ),
                  if (participant.badges.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        if (participant.hasStreak7Badge)
                          const ChallengeBadgeChip(badgeId: 'streak_7', compact: true),
                        if (participant.hasStreak30Badge)
                          const ChallengeBadgeChip(badgeId: 'streak_30', compact: true),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: ServerChallengeStrings.removeButton,
                child: IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.person_remove, color: scheme.error, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ColorScheme scheme) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: isCreator
          ? scheme.primary.withValues(alpha: 0.15)
          : scheme.outlineVariant.withValues(alpha: 0.35),
      child: Text(
        participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isCreator ? scheme.primary : scheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, ColorScheme scheme) {
    final (color, text) = _statusInfo(scheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  (Color, String) _statusInfo(ColorScheme scheme) {
    switch (participant.status) {
      case 'accepted':
        return (scheme.success, ServerChallengeStrings.inviteAccepted);
      case 'pending':
        return (scheme.warning, ServerChallengeStrings.invitePendingStatus);
      case 'rejected':
        return (scheme.error, ServerChallengeStrings.inviteDeclined);
      default:
        return (scheme.textMuted, participant.status);
    }
  }

  Color _backgroundColor(ColorScheme scheme) {
    if (isCreator) return scheme.primary.withValues(alpha: 0.05);
    switch (participant.status) {
      case 'accepted':
        return scheme.success.withValues(alpha: 0.04);
      case 'pending':
        return scheme.warning.withValues(alpha: 0.04);
      case 'rejected':
        return scheme.error.withValues(alpha: 0.04);
      default:
        return scheme.surfaceContainerHighest;
    }
  }

  Color _borderColor(ColorScheme scheme) {
    if (isCreator) return scheme.primary.withValues(alpha: 0.2);
    switch (participant.status) {
      case 'accepted':
        return scheme.success.withValues(alpha: 0.2);
      case 'pending':
        return scheme.warning.withValues(alpha: 0.2);
      case 'rejected':
        return scheme.error.withValues(alpha: 0.2);
      default:
        return Colors.transparent;
    }
  }
}
