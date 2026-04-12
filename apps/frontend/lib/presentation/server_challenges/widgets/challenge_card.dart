import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToDetail(),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildAmountRow(),
              const SizedBox(height: 8),
              _buildDateInfo(),
              if (challenge.isActive || challenge.isUpcoming) ...[
                const SizedBox(height: 16),
                _buildProgress(),
              ],
              const SizedBox(height: 16),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            challenge.name,
            style: getSemiBoldStyle(
              fontSize: FontSize.s18,
              color: ColorManager.darkGrey,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final (color, icon, text) = _getStatusInfo();

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

  (Color, IconData, String) _getStatusInfo() {
    if (challenge.achieved) {
      return (
        const Color(0xFF4CAF50),
        Icons.check_circle,
        ServerChallengeStrings.cardCompleted,
      );
    } else if (challenge.isExpired) {
      return (ColorManager.error, Icons.cancel, ServerChallengeStrings.cardExpired);
    } else if (challenge.isActive) {
      return (ColorManager.primary, Icons.trending_up, ServerChallengeStrings.cardActive);
    } else {
      return (
        const Color(0xFFFF9800),
        Icons.schedule,
        ServerChallengeStrings.cardUpcoming,
      );
    }
  }

  Widget _buildDateInfo() {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: ColorManager.grey1),
        const SizedBox(width: 8),
        Text(
          '${dateFormat.format(challenge.startDate)} - ${dateFormat.format(challenge.endDate)}',
          style: getRegularStyle(
            fontSize: FontSize.s14,
            color: ColorManager.grey1,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow() {
    return Row(
      children: [
        Icon(Icons.attach_money, size: 16, color: ColorManager.primary),
        const SizedBox(width: 8),
        Text(
          ServerChallengeStrings.goalAmount(challenge.amount),
          style: getBoldStyle(
            fontSize: FontSize.s16,
            color: ColorManager.primary,
          ),
        ),
        const Spacer(),
        if (challenge.acceptedParticipants.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              ServerChallengeStrings.acceptedCount(
                challenge.acceptedParticipants.length,
              ),
              style: getMediumStyle(
                fontSize: FontSize.s12,
                color: const Color(0xFF4CAF50),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgress() {
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
                color: ColorManager.grey1,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: getBoldStyle(
                fontSize: FontSize.s12,
                color: ColorManager.primary,
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
            backgroundColor: ColorManager.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              challenge.isUpcoming
                  ? const Color(0xFFFF9800)
                  : ColorManager.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        _buildParticipantsInfo(),
        const Spacer(),
        if (challenge.participants.length > 1)
          Icon(Icons.group, size: 16, color: ColorManager.grey1),
      ],
    );
  }

  Widget _buildParticipantsInfo() {
    final participantCount = challenge.participants.length;

    if (participantCount == 0) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        _buildAvatarStack(),
        const SizedBox(width: 8),
        Text(
          ServerChallengeStrings.participantCount(participantCount),
          style: getMediumStyle(
            fontSize: FontSize.s12,
            color: ColorManager.grey1,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarStack() {
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
              child: _buildAvatar(displayParticipants[i].name),
            ),
          if (remaining > 0)
            Positioned(
              left: displayParticipants.length * 20.0,
              child: _buildRemainingAvatar(remaining),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: ColorManager.primary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: getMediumStyle(
            fontSize: FontSize.s12,
            color: ColorManager.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildRemainingAvatar(int count) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: ColorManager.grey.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: getMediumStyle(
            fontSize: FontSize.s12,
            color: ColorManager.darkGrey,
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
