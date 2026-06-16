import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/resources/styles_manager.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_state.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_badge_chip.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_leaderboard_card.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/participant_item.dart';
import 'package:intl/intl.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/domain/repository/server_challenge_repository/server_challenge_repository.dart';

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

  double _getCurrentAmount(ChallengeModel challenge) {
    final me = challenge.participants.firstWhere(
      (p) => p.id == challenge.creatorId,
      orElse: () => challenge.participants.first,
    );
    final fromServer = me.currentProgress;
    if (fromServer > 0) return fromServer;
    return _repository.progressForChallenge(challenge.id, userId: me.id);
  }

  Future<void> _addProgress(ChallengeModel challenge, double amount) async {
    final me = challenge.participants.firstWhere(
      (p) => p.id == challenge.creatorId,
      orElse: () => challenge.participants.first,
    );
    final result = await ref
        .read(challengeOperationProvider.notifier)
        .addProgress(
          challengeId: challenge.id,
          amount: amount,
          userId: me.id,
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

    // Listen to operation state for updates
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

        if (next.challenge != null) {
          ref
              .read(challengeDetailProvider(widget.challengeId).notifier)
              .updateLocalChallenge(next.challenge!);
          ref.invalidate(challengeLeaderboardProvider(widget.challengeId));
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
          ServerChallengeStrings.detailTitle,
          style: getBoldStyle(
            fontSize: FontSize.s20,
            color: ColorManager.darkGrey,
          ),
        ),
        centerTitle: false,
      ),
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
      ChallengeDetailLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      ChallengeDetailError(:final message) => _buildError(message),
      ChallengeDetailLoaded(:final challenge, :final isOffline) =>
        Column(
          children: [
            if (isOffline) _buildOfflineBanner(),
            Expanded(child: _buildContent(challenge)),
          ],
        ),
    };
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
              color: ColorManager.error.withValues(alpha: 0.5),
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
                  .read(challengeDetailProvider(widget.challengeId).notifier)
                  .loadChallenge(),
              icon: const Icon(Icons.refresh),
              label: Text(ServerChallengeStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return MaterialBanner(
      content: Text(ServerChallengeStrings.offlineBanner),
      leading: const Icon(Icons.cloud_off_outlined),
      actions: [
        TextButton(
          onPressed: () => ref
              .read(challengeDetailProvider(widget.challengeId).notifier)
              .loadChallenge(),
          child: Text(ServerChallengeStrings.retry),
        ),
      ],
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
    final me = challenge.participants.firstWhere(
      (p) => p.id == challenge.creatorId,
      orElse: () => challenge.participants.first,
    );
    final today = DateTime.now().toIso8601String().split('T').first;
    final checkedToday = me.lastCheckIn == today;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Color(0xFFFF7043)),
                const SizedBox(width: 8),
                Text(
                  ServerChallengeStrings.streakTitle,
                  style: getBoldStyle(
                    fontSize: FontSize.s16,
                    color: ColorManager.darkGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ServerChallengeStrings.streakDays(me.streakDays),
              style: getBoldStyle(
                fontSize: FontSize.s20,
                color: ColorManager.primary,
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
              child: ElevatedButton.icon(
                onPressed: checkedToday
                    ? null
                    : () => ref
                        .read(challengeOperationProvider.notifier)
                        .checkIn(challengeId: challenge.id, userId: me.id),
                icon: const Icon(Icons.check_circle_outline),
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
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.name,
              style: getBoldStyle(
                fontSize: FontSize.s20,
                color: ColorManager.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.calendar_today,
              ServerChallengeStrings.startDateLabel,
              dateFormat.format(challenge.startDate),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.event,
              ServerChallengeStrings.endDateLabel,
              dateFormat.format(challenge.endDate),
            ),
            if (challenge.isActive || challenge.isUpcoming) ...[
              const SizedBox(height: 16),
              _buildProgressSection(challenge),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: ColorManager.grey1),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: getRegularStyle(
                  fontSize: FontSize.s12,
                  color: ColorManager.grey1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: getMediumStyle(
                  fontSize: FontSize.s14,
                  color: ColorManager.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(ChallengeModel challenge) {
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
              style: getMediumStyle(
                fontSize: FontSize.s14,
                color: ColorManager.grey1,
              ),
            ),
            Text(
              '${(challenge.progress * 100).toInt()}%',
              style: getBoldStyle(
                fontSize: FontSize.s16,
                color: ColorManager.primary,
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

  Widget _buildStatusCard(ChallengeModel challenge) {
    final currentAmount = _getCurrentAmount(challenge);
    final targetAmount =
        challenge.participants
            .firstWhere(
              (p) => p.id == challenge.creatorId,
              orElse: () => challenge.participants.first,
            )
            .targetAmount ??
        0.0;
    final progress = targetAmount > 0
        ? (currentAmount / targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final isAchieved = currentAmount >= targetAmount && targetAmount > 0;

    final (color, icon, text) = isAchieved
        ? (
            const Color(0xFF4CAF50),
            Icons.check_circle,
            ServerChallengeStrings.cardCompleted,
          )
        : challenge.isExpired
        ? (ColorManager.error, Icons.cancel, ServerChallengeStrings.cardExpired)
        : challenge.isActive
        ? (
            ColorManager.primary,
            Icons.trending_up,
            ServerChallengeStrings.cardActive,
          )
        : (
            const Color(0xFFFF9800),
            Icons.schedule,
            ServerChallengeStrings.cardUpcoming,
          );

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
                        style: getRegularStyle(
                          fontSize: FontSize.s12,
                          color: ColorManager.grey1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        text,
                        style: getBoldStyle(
                          fontSize: FontSize.s18,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!challenge.isExpired) ...[
              const SizedBox(height: 24),
              // Target and Current Amount Display
              Row(
                children: [
                  Expanded(
                    child: _buildAmountBox(
                      ServerChallengeStrings.targetAmountLabel,
                      targetAmount,
                      ColorManager.primary,
                      Icons.flag,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAmountBox(
                      ServerChallengeStrings.currentAmountLabel,
                      currentAmount,
                      isAchieved ? const Color(0xFF4CAF50) : ColorManager.grey1,
                      Icons.account_balance_wallet,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ServerChallengeStrings.progressLabel,
                        style: getMediumStyle(
                          fontSize: FontSize.s14,
                          color: ColorManager.grey1,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: getBoldStyle(
                          fontSize: FontSize.s14,
                          color: isAchieved
                              ? const Color(0xFF4CAF50)
                              : ColorManager.primary,
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
                      backgroundColor: ColorManager.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isAchieved
                            ? const Color(0xFF4CAF50)
                            : ColorManager.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Update Amount Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showUpdateAmountDialog(challenge),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAchieved
                        ? const Color(0xFF4CAF50)
                        : ColorManager.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(isAchieved ? Icons.check_circle : Icons.edit),
                  label: Text(
                    isAchieved
                        ? ServerChallengeStrings.updateAmountAchieved
                        : ServerChallengeStrings.updateAmountButton,
                    style: getBoldStyle(
                      fontSize: FontSize.s16,
                      color: Colors.white,
                    ),
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
                  style: getRegularStyle(
                    fontSize: FontSize.s12,
                    color: ColorManager.grey1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ServerChallengeStrings.formatAmount(amount),
            style: getBoldStyle(fontSize: FontSize.s18, color: color),
          ),
        ],
      ),
    );
  }

  // Update the _showUpdateAmountDialog to show current amount and accept new amount to add
  void _showUpdateAmountDialog(ChallengeModel challenge) {
    final currentAmount = _getCurrentAmount(challenge);
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ServerChallengeStrings.addAmountTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorManager.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    ServerChallengeStrings.currentAmountLabel,
                    style: getRegularStyle(
                      fontSize: FontSize.s12,
                      color: ColorManager.grey1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ServerChallengeStrings.formatAmount(currentAmount),
                    style: getBoldStyle(
                      fontSize: FontSize.s20,
                      color: ColorManager.primary,
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
                prefixIcon: const Icon(Icons.add),
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Text(
              ServerChallengeStrings.creatorTargetLine(
                challenge.participants
                        .firstWhere(
                          (p) => p.id == challenge.creatorId,
                          orElse: () => challenge.participants.first,
                        )
                        .targetAmount
                        ?.toStringAsFixed(2) ??
                    '0.00',
              ),
              style: getRegularStyle(
                fontSize: FontSize.s14,
                color: ColorManager.grey1,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(ServerChallengeStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final amountToAdd = double.tryParse(amountController.text.trim());
              if (amountToAdd != null && amountToAdd > 0) {
                Navigator.pop(context);
                await _addProgress(challenge, amountToAdd);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ServerChallengeStrings.invalidAmountSnack),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: Text(ServerChallengeStrings.addAmountSubmit),
          ),
        ],
      ),
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
                  style: getBoldStyle(
                    fontSize: FontSize.s16,
                    color: ColorManager.darkGrey,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showInviteDialog(challenge),
                  icon: const Icon(Icons.person_add, size: 18),
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ServerChallengeStrings.inviteDialogTitle),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: ServerChallengeStrings.inviteEmailLabel,
            hintText: ServerChallengeStrings.inviteEmailHint,
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(ServerChallengeStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              final isValidEmail = RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              ).hasMatch(email);
              if (!isValidEmail) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ServerChallengeStrings.inviteInvalidEmail),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              ref
                  .read(challengeOperationProvider.notifier)
                  .inviteUser(challengeId: challenge.id, email: email);
            },
            child: Text(ServerChallengeStrings.inviteButton),
          ),
        ],
      ),
    );
  }

  void _removeParticipant(ChallengeModel challenge, int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ServerChallengeStrings.removeParticipantTitle),
        content: Text(ServerChallengeStrings.removeParticipantBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(ServerChallengeStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(challengeOperationProvider.notifier)
                  .removeParticipant(challengeId: challenge.id, userId: userId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorManager.error,
            ),
            child: Text(ServerChallengeStrings.removeButton),
          ),
        ],
      ),
    );
  }
}
