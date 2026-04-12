import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:mudabbir/persentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/persentation/resources/font_manager.dart';
import 'package:mudabbir/persentation/resources/styles_manager.dart';
import 'package:mudabbir/persentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/persentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/persentation/server_challenges/providers/challenge_state.dart';
import 'package:intl/intl.dart';

class PendingInvitationsScreen extends ConsumerStatefulWidget {
  const PendingInvitationsScreen({super.key});

  @override
  ConsumerState<PendingInvitationsScreen> createState() =>
      _PendingInvitationsScreenState();
}

class _PendingInvitationsScreenState
    extends ConsumerState<PendingInvitationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(pendingInvitationsProvider.notifier)
          .loadPendingInvitations(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pendingInvitationsProvider);

    // Listen to operation state
    ref.listen<ChallengeOperationState>(challengeOperationProvider, (
      previous,
      next,
    ) {
      if (next is ChallengeOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        // Remove from pending list if accepted/rejected
        if (next.challenge != null) {
          ref
              .read(pendingInvitationsProvider.notifier)
              .removeInvitation(next.challenge!.id);
        }
      } else if (next is ChallengeOperationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: ColorManager.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: AppBar(
        title: Text(
          ServerChallengeStrings.pendingTitle,
          style: getBoldStyle(
            fontSize: FontSize.s20,
            color: ColorManager.darkGrey,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => ref
                .read(pendingInvitationsProvider.notifier)
                .loadPendingInvitations(),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildBody(state),
        ),
      ),
    );
  }

  Widget _buildBody(ChallengeState state) {
    return switch (state) {
      ChallengeInitial() => const SizedBox.shrink(),
      ChallengeLoading() => const Center(child: CircularProgressIndicator()),
      ChallengeError(:final message) => _buildError(message),
      ChallengeLoaded(:final challenges) => _buildInvitations(challenges),
    };
  }

  Widget _buildInvitations(List<ChallengeModel> challenges) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: ColorManager.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              ServerChallengeStrings.pendingEmpty,
              style: getMediumStyle(
                fontSize: FontSize.s16,
                color: ColorManager.grey1,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return _buildInvitationCard(challenges[index]);
      },
    );
  }

  Widget _buildInvitationCard(ChallengeModel challenge) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final operationState = ref.watch(challengeOperationProvider);
    final isLoading = operationState is ChallengeOperationLoading;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: const Color(0xFFFF9800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ServerChallengeStrings.pendingStatus,
                        style: getMediumStyle(
                          fontSize: FontSize.s12,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: ColorManager.grey1),
                const SizedBox(width: 8),
                Text(
                  ServerChallengeStrings.fromCreator(challenge.creator.name),
                  style: getRegularStyle(
                    fontSize: FontSize.s14,
                    color: ColorManager.grey1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: ColorManager.grey1),
                const SizedBox(width: 8),
                Text(
                  ServerChallengeStrings.totalAmount(challenge.amount),
                  style: getMediumStyle(
                    fontSize: FontSize.s14,
                    color: ColorManager.darkGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
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
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.group, size: 16, color: ColorManager.grey1),
                const SizedBox(width: 8),
                Text(
                  ServerChallengeStrings.acceptedBeforeInvite(
                    challenge.acceptedParticipants.length,
                  ),
                  style: getRegularStyle(
                    fontSize: FontSize.s14,
                    color: ColorManager.grey1,
                  ),
                ),
              ],
            ),
            if (challenge.acceptedParticipants.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: ColorManager.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ServerChallengeStrings.splitHint,
                        style: getRegularStyle(
                          fontSize: FontSize.s12,
                          color: ColorManager.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _handleReject(challenge.id),
                    icon: const Icon(Icons.close),
                    label: Text(ServerChallengeStrings.decline),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorManager.error,
                      side: BorderSide(color: ColorManager.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _handleAccept(challenge.id),
                    icon: const Icon(Icons.check),
                    label: Text(ServerChallengeStrings.accept),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: ColorManager.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: getMediumStyle(
                fontSize: FontSize.s16,
                color: ColorManager.darkGrey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(pendingInvitationsProvider.notifier)
                  .loadPendingInvitations(),
              icon: const Icon(Icons.refresh),
              label: Text(ServerChallengeStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAccept(int challengeId) {
    ref
        .read(challengeOperationProvider.notifier)
        .respondToInvitation(challengeId: challengeId, accept: true);
  }

  void _handleReject(int challengeId) {
    ref
        .read(challengeOperationProvider.notifier)
        .respondToInvitation(challengeId: challengeId, accept: false);
  }
}
