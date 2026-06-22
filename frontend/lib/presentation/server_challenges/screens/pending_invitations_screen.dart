import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_state.dart';
import 'package:mudabbir/presentation/widgets/app_animated_list_item.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/service/haptic_service.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(pendingInvitationsProvider);

    ref.listen<ChallengeOperationState>(challengeOperationProvider, (
      previous,
      next,
    ) {
      if (next is ChallengeOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (next.challenge != null) {
          ref
              .read(pendingInvitationsProvider.notifier)
              .removeInvitation(next.challenge!.id);
        }
      } else if (next is ChallengeOperationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: scheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return AppGroupedScaffold(
      titleText: ServerChallengeStrings.pendingTitle,
      actions: [
        IconButton(
          tooltip: ServerChallengeStrings.retry,
          onPressed: () => ref
              .read(pendingInvitationsProvider.notifier)
              .loadPendingInvitations(),
          icon: const Icon(CupertinoIcons.refresh),
        ),
      ],
      body: SafeArea(top: false, child: _buildBody(state)),
    );
  }

  Widget _buildBody(ChallengeState state) {
    return switch (state) {
      ChallengeInitial() => const SizedBox.shrink(),
      ChallengeLoading() => const AppListSkeleton(),
      ChallengeError(:final message) => _buildError(message),
      ChallengeLoaded(:final challenges) => _buildInvitations(challenges),
    };
  }

  Widget _buildInvitations(List<ChallengeModel> challenges) {
    if (challenges.isEmpty) {
      return Center(
        child: IOSEmptyState(
          icon: Icons.mail_outline_rounded,
          title: ServerChallengeStrings.pendingEmpty,
          subtitle: ServerChallengeStrings.pendingEmptySubtitle,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppLayout.pageGutter),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return AppAnimatedListItem(
          index: index,
          child: _buildInvitationCard(challenges[index]),
        );
      },
    );
  }

  Widget _buildInvitationCard(ChallengeModel challenge) {
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy');
    final operationState = ref.watch(challengeOperationProvider);
    final isLoading = operationState is ChallengeOperationLoading;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppLayout.sectionGap),
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
          _infoRow(
            Icons.person_outline,
            ServerChallengeStrings.fromCreator(challenge.creator.name),
          ),
          const SizedBox(height: 8),
          _infoRow(
            Icons.payments_outlined,
            ServerChallengeStrings.totalAmount(challenge.amount),
          ),
          const SizedBox(height: 8),
          _infoRow(
            Icons.calendar_today_outlined,
            '${dateFormat.format(challenge.startDate)} - ${dateFormat.format(challenge.endDate)}',
          ),
          const SizedBox(height: 8),
          _infoRow(
            Icons.group_outlined,
            ServerChallengeStrings.acceptedBeforeInvite(
              challenge.acceptedParticipants.length,
            ),
          ),
          if (challenge.acceptedParticipants.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.groupedFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: scheme.chromeIcon),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ServerChallengeStrings.splitHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface,
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
                      : () {
                          HapticService.light();
                          _handleReject(challenge.id);
                        },
                  icon: const Icon(Icons.close_rounded),
                  label: Text(ServerChallengeStrings.decline),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                    side: BorderSide(color: scheme.error.withValues(alpha: 0.7)),
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
                          _handleAccept(challenge.id);
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

  Widget _infoRow(IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: IOSEmptyState(
        icon: Icons.error_outline_rounded,
        title: message,
        iconColor: Theme.of(context).colorScheme.error,
        buttonLabel: ServerChallengeStrings.retry,
        onPressed: () => ref
            .read(pendingInvitationsProvider.notifier)
            .loadPendingInvitations(),
      ),
    );
  }

  void _handleAccept(int challengeId) {
    ref.read(challengeOperationProvider.notifier).respondToInvitation(
          challengeId: challengeId,
          accept: true,
        );
  }

  void _handleReject(int challengeId) {
    ref.read(challengeOperationProvider.notifier).respondToInvitation(
          challengeId: challengeId,
          accept: false,
        );
  }
}
