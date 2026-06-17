import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/resources/styles_manager.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/screens/challenge_detail_screen.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:intl/intl.dart';

class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;

  const ChallengeCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: scheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        side: BorderSide(
          color: scheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(),
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(scheme),
              const SizedBox(height: 12),
              _buildAmountRow(scheme),
              const SizedBox(height: 8),
              _buildDateInfo(scheme),
              if (challenge.isActive || challenge.isUpcoming) ...[
                const SizedBox(height: 16),
                _buildProgress(scheme),
              ],
              const SizedBox(height: 16),
              _buildFooter(scheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme scheme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            challenge.name,
            style: getSemiBoldStyle(
              fontSize: FontSize.s18,
              color: scheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        _buildStatusBadge(scheme),
      ],
    );
  }

  Widget _buildStatusBadge(ColorScheme scheme) {
    final (color, icon, text) = _getStatusInfo(scheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: getMediumStyle(fontSize: FontSize.s12, color: color),
          ),
        ],
      ),
    );
  }

  (Color, IconData, String) _getStatusInfo(ColorScheme scheme) {
    if (challenge.achieved) {
      return (
        scheme.success,
        Icons.check_circle,
        ServerChallengeStrings.cardCompleted,
      );
    } else if (challenge.isExpired) {
      return (
        scheme.error,
        Icons.cancel,
        ServerChallengeStrings.cardExpired,
      );
    } else if (challenge.isActive) {
      return (
        scheme.primary,
        Icons.trending_up,
        ServerChallengeStrings.cardActive,
      );
    } else {
      return (
        scheme.warning,
        Icons.schedule,
        ServerChallengeStrings.cardUpcoming,
      );
    }
  }

  Widget _buildDateInfo(ColorScheme scheme) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: scheme.textMuted),
        const SizedBox(width: 8),
        Text(
          '${dateFormat.format(challenge.startDate)} - ${dateFormat.format(challenge.endDate)}',
          style: getRegularStyle(
            fontSize: FontSize.s14,
            color: scheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(ColorScheme scheme) {
    return Row(
      children: [
        Icon(Icons.attach_money, size: 16, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          ServerChallengeStrings.goalAmount(challenge.amount),
          style: getBoldStyle(
            fontSize: FontSize.s16,
            color: scheme.primary,
          ),
        ),
        const Spacer(),
        if (challenge.acceptedParticipants.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              ServerChallengeStrings.acceptedCount(
                challenge.acceptedParticipants.length,
              ),
              style: getMediumStyle(
                fontSize: FontSize.s12,
                color: scheme.success,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgress(ColorScheme scheme) {
    final daysRemaining = challenge.daysRemaining;
    final progress = challenge.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              challenge.isUpcoming
                  ? ServerChallengeStrings.daysUntilStart(daysRemaining)
                  : ServerChallengeStrings.daysRemaining(daysRemaining),
              style: getMediumStyle(
                fontSize: FontSize.s12,
                color: scheme.textMuted,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: getBoldStyle(
                fontSize: FontSize.s12,
                color: scheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: scheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              challenge.isUpcoming ? scheme.warning : scheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme scheme) {
    return Row(
      children: [
        _buildParticipantsInfo(scheme),
        const Spacer(),
        if (challenge.participants.length > 1)
          Icon(Icons.group, size: 16, color: scheme.textMuted),
      ],
    );
  }

  Widget _buildParticipantsInfo(ColorScheme scheme) {
    final participantCount = challenge.participants.length;

    if (participantCount == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        _buildAvatarStack(scheme),
        const SizedBox(width: 8),
        Text(
          ServerChallengeStrings.participantCount(participantCount),
          style: getMediumStyle(
            fontSize: FontSize.s12,
            color: scheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStack(ColorScheme scheme) {
    final displayParticipants = challenge.participants
        .take(3)
        .toList(); // Show max 3 avatars
    final remaining = challenge.participants.length - 3;

    return SizedBox(
      width: displayParticipants.length * 20.0 + (remaining > 0 ? 20 : 0),
      height: 32,
      child: Stack(
        children: [
          for (int i = 0; i < displayParticipants.length; i++)
            Positioned(
              left: i * 20.0,
              child: _buildAvatar(scheme, displayParticipants[i].name),
            ),
          if (remaining > 0)
            Positioned(
              left: displayParticipants.length * 20.0,
              child: _buildRemainingAvatar(scheme, remaining),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ColorScheme scheme, String name) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: scheme.surface, width: 2),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: getMediumStyle(
            fontSize: FontSize.s12,
            color: scheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildRemainingAvatar(ColorScheme scheme, int count) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(color: scheme.surface, width: 2),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: getMediumStyle(
            fontSize: FontSize.s12,
            color: scheme.textMuted,
          ),
        ),
      ),
    );
  }

  void _navigateToDetail() {
    getIt<NavigationService>().navigate(
      ChallengeDetailScreen(challengeId: challenge.id),
    );
  }
}
