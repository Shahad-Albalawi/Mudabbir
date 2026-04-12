import 'package:flutter/material.dart';
import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:mudabbir/persentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/persentation/resources/font_manager.dart';
import 'package:mudabbir/persentation/resources/styles_manager.dart';
import 'package:mudabbir/persentation/server_challenges/models/challenge_model.dart';

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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Row(
        children: [
          _buildAvatar(),
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
                        style: getMediumStyle(
                          fontSize: FontSize.s14,
                          color: ColorManager.darkGrey,
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
                          color: ColorManager.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ServerChallengeStrings.roleCreator,
                          style: getMediumStyle(
                            fontSize: FontSize.s12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  participant.email,
                  style: getRegularStyle(
                    fontSize: FontSize.s12,
                    color: ColorManager.grey1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(),
                    const SizedBox(width: 8),
                    if (participant.targetAmount != null) ...[
                      Icon(Icons.flag, size: 12, color: ColorManager.primary),
                      const SizedBox(width: 4),
                      Text(
                        '\$${participant.targetAmount!.toStringAsFixed(2)}',
                        style: getMediumStyle(
                          fontSize: FontSize.s12,
                          color: ColorManager.primary,
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
                            ? const Color(0xFF4CAF50)
                            : ColorManager.grey,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.person_remove,
                color: ColorManager.error,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getAvatarColor(),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?',
          style: getBoldStyle(
            fontSize: FontSize.s18,
            color: isCreator ? ColorManager.primary : ColorManager.darkGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final (color, text) = _getStatusInfo();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: getMediumStyle(fontSize: FontSize.s12, color: color),
      ),
    );
  }

  (Color, String) _getStatusInfo() {
    switch (participant.status) {
      case 'accepted':
        return (const Color(0xFF4CAF50), ServerChallengeStrings.inviteAccepted);
      case 'pending':
        return (
          const Color(0xFFFF9800),
          ServerChallengeStrings.invitePendingStatus,
        );
      case 'rejected':
        return (ColorManager.error, ServerChallengeStrings.inviteDeclined);
      default:
        return (ColorManager.grey, participant.status);
    }
  }

  Color _getBackgroundColor() {
    if (isCreator) {
      return ColorManager.primary.withValues(alpha: 0.05);
    }
    switch (participant.status) {
      case 'accepted':
        return const Color(0xFF4CAF50).withValues(alpha: 0.03);
      case 'pending':
        return const Color(0xFFFF9800).withValues(alpha: 0.03);
      case 'rejected':
        return ColorManager.error.withValues(alpha: 0.03);
      default:
        return ColorManager.grey.withValues(alpha: 0.05);
    }
  }

  Color _getBorderColor() {
    if (isCreator) {
      return ColorManager.primary.withValues(alpha: 0.2);
    }
    switch (participant.status) {
      case 'accepted':
        return const Color(0xFF4CAF50).withValues(alpha: 0.2);
      case 'pending':
        return const Color(0xFFFF9800).withValues(alpha: 0.2);
      case 'rejected':
        return ColorManager.error.withValues(alpha: 0.2);
      default:
        return Colors.transparent;
    }
  }

  Color _getAvatarColor() {
    if (isCreator) {
      return ColorManager.primary.withValues(alpha: 0.2);
    }
    return ColorManager.grey.withValues(alpha: 0.2);
  }
}
