import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mudabbir/domain/repository/server_challenge_repository/server_challenge_repository.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/server_challenges/challenge_copy_helpers.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_state.dart';
import 'package:mudabbir/presentation/server_challenges/utils/challenge_check_in_utils.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_badge_chip.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_leaderboard_card.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/participant_item.dart';
import 'package:mudabbir/presentation/widgets/app_snackbar.dart';
import 'package:mudabbir/presentation/widgets/app_confirm_dialog.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/presentation/widgets/app_offline_banner.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:mudabbir/utils/challenge_current_user.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final int challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  ServerChallengeRepository get _repository =>
      getIt<ServerChallengeRepository>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(challengeDetailProvider(widget.challengeId).notifier)
          .loadChallenge();
    });
  }

  ParticipantModel? _me(ChallengeModel challenge) =>
      ChallengeCurrentUser.participantIn(challenge);

  double _getCurrentAmount(ChallengeModel challenge) {
    final me = _me(challenge);
    if (me == null) return 0;
    final fromServer = me.currentProgress;
    if (fromServer > 0) return fromServer;
    return _repository.progressForChallenge(challenge.id);
  }

  Future<void> _addProgress(ChallengeModel challenge, double amount) async {
    final result = await ref
        .read(challengeOperationProvider.notifier)
        .addProgress(
          challengeId: challenge.id,
          amount: amount,
        );
    if (result?.challenge != null && mounted) {
      ref
          .read(challengeDetailProvider(widget.challengeId).notifier)
          .updateLocalChallenge(result!.challenge!);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(challengeDetailProvider(widget.challengeId));

    ref.listen<ChallengeOperationState>(challengeOperationProvider, (
      previous,
      next,
    ) {
      if (next is ChallengeOperationSuccess) {
        AppSnackbar.success(next.message);

        if (next.challenge != null) {
          ref
              .read(challengeDetailProvider(widget.challengeId).notifier)
              .updateLocalChallenge(next.challenge!);
          ref.invalidate(challengeLeaderboardProvider(widget.challengeId));
        }
      } else if (next is ChallengeOperationError) {
        AppSnackbar.error(next.message);
      }
    });

    return AppGroupedScaffold(
      backFallbackRoute: AppRoutes.challenges,
      titleText: ServerChallengeStrings.detailTitle,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildBody(detailState),
        ),
      ),
    );
  }

  Widget _buildBody(ChallengeDetailState state) {
    return switch (state) {
      ChallengeDetailInitial() => const SizedBox.shrink(),
      ChallengeDetailLoading() => const AppSummarySkeleton(),
      ChallengeDetailError(:final message) => _buildError(message),
      ChallengeDetailLoaded(:final challenge, :final isOffline) =>
        Column(
          children: [
            if (isOffline)
              AppOfflineBanner(
                message: ServerChallengeStrings.offlineBanner,
                onRetry: () => ref
                    .read(challengeDetailProvider(widget.challengeId).notifier)
                    .loadChallenge(),
              ),
            Expanded(child: _buildContent(challenge)),
          ],
        ),
    };
  }

  Widget _buildError(String message) {
    final isServerError = message.contains('503') ||
        message.toLowerCase().contains('server') ||
        message.toLowerCase().contains('maintenance');

    return Center(
      child: IOSEmptyState(
        icon: isServerError
            ? CupertinoIcons.cloud
            : CupertinoIcons.exclamationmark_circle,
        title: message,
        subtitle: isServerError ? ServerChallengeStrings.serverMaintenanceHint : '',
        buttonLabel: ServerChallengeStrings.retry,
        onPressed: () => ref
            .read(challengeDetailProvider(widget.challengeId).notifier)
            .loadChallenge(),
      ),
    );
  }

  Widget _buildContent(ChallengeModel challenge) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(challenge),
          const SizedBox(height: 16),
          _buildStreakCard(challenge),
          const SizedBox(height: 16),
          _buildStatusCard(challenge),
          const SizedBox(height: 16),
          ChallengeLeaderboardCard(challengeId: challenge.id),
          const SizedBox(height: 16),
          _buildParticipantsCard(challenge),
        ],
      ),
    );
  }

  Widget _buildStreakCard(ChallengeModel challenge) {
    final me = _me(challenge);
    if (me == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final checkedToday = ChallengeCheckInUtils.isCheckedInToday(me);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.flame_fill, color: scheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  ServerChallengeStrings.streakTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ServerChallengeStrings.streakDays(me.streakDays),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.dataGreen,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (me.badges.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  if (me.hasStreak7Badge)
                    const ChallengeBadgeChip(badgeId: 'streak_7'),
                  if (me.hasStreak30Badge)
                    const ChallengeBadgeChip(badgeId: 'streak_30'),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: checkedToday
                    ? null
                    : () => ref
                        .read(challengeOperationProvider.notifier)
                        .checkIn(challengeId: challenge.id),
                icon: const Icon(CupertinoIcons.checkmark_circle),
                label: Text(
                  checkedToday
                      ? ServerChallengeStrings.alreadyCheckedIn
                      : ServerChallengeStrings.checkInButton,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ChallengeModel challenge) {
    final scheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              CupertinoIcons.calendar,
              ServerChallengeStrings.startDateLabel,
              dateFormat.format(challenge.startDate),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              CupertinoIcons.calendar_today,
              ServerChallengeStrings.endDateLabel,
              dateFormat.format(challenge.endDate),
            ),
            if (challenge.isActive || challenge.isUpcoming) ...[
              const SizedBox(height: 16),
              _buildProgressSection(challenge, scheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.textMuted,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(ChallengeModel challenge, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              challenge.isUpcoming
                  ? ServerChallengeStrings.daysUntilStart(
                      challenge.daysRemaining,
                    )
                  : ServerChallengeStrings.daysRemaining(
                      challenge.daysRemaining,
                    ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.textMuted,
                  ),
            ),
            Text(
              '${(challenge.progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.dataGreen,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: challenge.progress,
            minHeight: 12,
            backgroundColor: scheme.outlineVariant.withValues(alpha: 0.35),
            valueColor: AlwaysStoppedAnimation<Color>(
              challenge.isUpcoming ? scheme.tertiary : scheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(ChallengeModel challenge) {
    final scheme = Theme.of(context).colorScheme;
    final me = _me(challenge);
    final currentAmount = _getCurrentAmount(challenge);
    final targetAmount = me?.targetAmount ?? 0.0;
    final progress = targetAmount > 0
        ? (currentAmount / targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final isAchieved = currentAmount >= targetAmount && targetAmount > 0;

    final (color, icon, text) = isAchieved
        ? (scheme.tertiary, CupertinoIcons.checkmark_seal_fill, ServerChallengeStrings.cardCompleted)
        : challenge.isExpired
            ? (scheme.error, CupertinoIcons.xmark_circle_fill, ServerChallengeStrings.cardExpired)
            : challenge.isActive
                ? (scheme.primary, CupertinoIcons.flame_fill, ServerChallengeStrings.cardActive)
                : (scheme.tertiary, CupertinoIcons.time, ServerChallengeStrings.cardUpcoming);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ServerChallengeStrings.statusLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.textMuted,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        text,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!challenge.isExpired && me != null) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildAmountBox(
                      ServerChallengeStrings.targetAmountLabel,
                      targetAmount,
                      scheme.dataGreen,
                      AppIcons.goals,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAmountBox(
                      ServerChallengeStrings.currentAmountLabel,
                      currentAmount,
                      isAchieved ? scheme.tertiary : scheme.dataGreen,
                      AppIcons.wallet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ServerChallengeStrings.progressLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.textMuted,
                            ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isAchieved ? scheme.tertiary : scheme.dataGreen,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: scheme.outlineVariant.withValues(alpha: 0.35),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isAchieved ? scheme.tertiary : scheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showUpdateAmountDialog(challenge),
                  icon: Icon(
                    isAchieved
                        ? CupertinoIcons.checkmark_seal_fill
                        : CupertinoIcons.pencil,
                  ),
                  label: Text(
                    isAchieved
                        ? ServerChallengeStrings.updateAmountAchieved
                        : ServerChallengeStrings.updateAmountButton,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBox(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.textMuted,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ServerChallengeStrings.formatAmount(amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  void _showUpdateAmountDialog(ChallengeModel challenge) {
    final scheme = Theme.of(context).colorScheme;
    final me = _me(challenge);
    final currentAmount = _getCurrentAmount(challenge);
    final amountController = TextEditingController();
    var saving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            return Dialog(
              shape: IOSDialogStyle.dialogShape(),
              child: Container(
                width: MediaQuery.of(dialogContext).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: IOSDialogStyle.surfaceDecoration(dialogContext),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IOSDialogStyle.header(
                      dialogContext,
                      title: ServerChallengeStrings.addAmountTitle,
                      icon: CupertinoIcons.plus_circle,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: scheme.groupedFill,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  ServerChallengeStrings.currentAmountLabel,
                                  style: Theme.of(dialogContext)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: scheme.textMuted),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ServerChallengeStrings.formatAmount(
                                    currentAmount,
                                  ),
                                  style: Theme.of(dialogContext)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: scheme.dataGreen,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: amountController,
                            decoration: InputDecoration(
                              labelText: ServerChallengeStrings.addAmountLabel,
                              hintText: ServerChallengeStrings.addAmountHint,
                              prefixIcon: const Icon(CupertinoIcons.add),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            autofocus: true,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ServerChallengeStrings.creatorTargetLine(
                              me?.targetAmount?.toStringAsFixed(2) ?? '0.00',
                            ),
                            style: Theme.of(dialogContext)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: scheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: saving
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              child: Text(ServerChallengeStrings.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppLoadingButton(
                              isLoading: saving,
                              label: ServerChallengeStrings.addAmountSubmit,
                              onPressed: () async {
                                final amountToAdd = double.tryParse(
                                  amountController.text.trim(),
                                );
                                if (amountToAdd == null || amountToAdd <= 0) {
                                  AppSnackbar.warning(
                                    ServerChallengeStrings.invalidAmountSnack,
                                  );
                                  return;
                                }

                                setLocalState(() => saving = true);
                                await _addProgress(challenge, amountToAdd);
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildParticipantsCard(ChallengeModel challenge) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ServerChallengeStrings.participantsTitle(
                    challenge.participants.length,
                  ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton.icon(
                  onPressed: () => _showInviteDialog(challenge),
                  icon: const Icon(CupertinoIcons.person_add, size: 18),
                  label: Text(ServerChallengeStrings.inviteButton),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...challenge.participants.map((participant) {
              return ParticipantItem(
                participant: participant,
                isCreator: participant.id == challenge.creatorId,
                onRemove: participant.id != challenge.creatorId
                    ? () => _removeParticipant(challenge, participant.id)
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog(ChallengeModel challenge) {
    final emailController = TextEditingController();
    var saving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            return Dialog(
              shape: IOSDialogStyle.dialogShape(),
              child: Container(
                width: MediaQuery.of(dialogContext).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: IOSDialogStyle.surfaceDecoration(dialogContext),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IOSDialogStyle.header(
                      dialogContext,
                      title: ServerChallengeStrings.inviteDialogTitle,
                      icon: CupertinoIcons.person_add,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: ServerChallengeStrings.inviteEmailLabel,
                          hintText: ServerChallengeStrings.inviteEmailHint,
                          prefixIcon: const Icon(CupertinoIcons.mail),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: saving
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              child: Text(ServerChallengeStrings.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppLoadingButton(
                              isLoading: saving,
                              label: ServerChallengeStrings.inviteButton,
                              onPressed: () {
                                final email = emailController.text.trim();
                                final isValidEmail = RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                ).hasMatch(email);
                                if (!isValidEmail) {
                                  AppSnackbar.warning(
                                    ServerChallengeStrings.inviteInvalidEmail,
                                  );
                                  return;
                                }

                                setLocalState(() => saving = true);
                                Navigator.pop(dialogContext);
                                ref
                                    .read(
                                      challengeOperationProvider.notifier,
                                    )
                                    .inviteUser(
                                      challengeId: challenge.id,
                                      email: email,
                                    );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _removeParticipant(ChallengeModel challenge, int userId) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: ServerChallengeStrings.removeParticipantTitle,
      message: ServerChallengeStrings.removeParticipantBody,
      confirmLabel: ServerChallengeStrings.removeButton,
      cancelLabel: ServerChallengeStrings.cancel,
    );
    if (confirmed == true && mounted) {
      ref
          .read(challengeOperationProvider.notifier)
          .removeParticipant(challengeId: challenge.id, userId: userId);
    }
  }
}
