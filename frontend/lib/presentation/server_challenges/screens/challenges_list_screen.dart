import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_state.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_card.dart';
import 'package:mudabbir/presentation/widgets/app_animated_list_item.dart';
import 'package:mudabbir/presentation/widgets/app_offline_banner.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_templates_strip.dart';
class ChallengesListScreen extends ConsumerStatefulWidget {
  const ChallengesListScreen({super.key});

  @override
  ConsumerState<ChallengesListScreen> createState() =>
      _ChallengesListScreenState();
}

class _ChallengesListScreenState extends ConsumerState<ChallengesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Load challenges on screen init
    Future.microtask(() {
      ref.read(challengesProvider.notifier).loadChallenges();
      // Also load pending invitations to show count
      ref.read(pendingInvitationsProvider.notifier).loadPendingInvitations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challengeState = ref.watch(challengesProvider);

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
        ref.read(challengeOperationProvider.notifier).reset();
      }
    });

    final pendingState = ref.watch(pendingInvitationsProvider);
    int pendingCount = 0;
    if (pendingState is ChallengeLoaded) {
      pendingCount = pendingState.challenges.length;
    }

    return AppGroupedScaffold(
      onBackPressed: () => Navigator.pop(context),
      largeTitle: true,
      titleText: ServerChallengeStrings.listTitle,
      actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () => _navigateToPendingInvitations(context),
                icon: const Icon(CupertinoIcons.bell),
              ),
              if (pendingCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$pendingCount',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () =>
                ref.read(challengesProvider.notifier).refreshChallenges(),
            icon: const Icon(CupertinoIcons.refresh),
          ),
        ],
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Column(
                children: [
                  if (challengeState is ChallengeLoaded &&
                      challengeState.isOffline)
                    AppOfflineBanner(
                      message: ServerChallengeStrings.offlineBanner,
                      onRetry: () => ref
                          .read(challengesProvider.notifier)
                          .refreshChallenges(),
                    ),
                  Expanded(child: _buildBody(challengeState)),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Semantics(
        label: ServerChallengeStrings.newChallengeFab,
        button: true,
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticService.medium();
            _navigateToCreateChallenge(context);
          },
          icon: const Icon(CupertinoIcons.add),
          label: Text(ServerChallengeStrings.newChallengeFab),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: scheme.primary,
        unselectedLabelColor: scheme.textMuted,
        // labelStyle: getMediumStyle(fontSize: FontSize.s14),
        // unselectedLabelStyle: getMediumStyle(fontSize: FontSize.s12),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        indicatorPadding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        dividerColor: Colors.transparent,
        isScrollable: false, // Make tabs equally distributed
        tabs: [
          Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                ServerChallengeStrings.tabActive,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                ServerChallengeStrings.tabUpcoming,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                ServerChallengeStrings.tabCompleted,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                ServerChallengeStrings.tabExpired,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ChallengeState state) {
    return switch (state) {
      ChallengeInitial() => const SizedBox.shrink(),
      ChallengeLoading() => const AppListSkeleton(),
      ChallengeError(:final message) => _buildError(message),
      ChallengeLoaded() => _buildTabBarView(state),
    };
  }

  Widget _buildTabBarView(ChallengeLoaded state) {
    return Column(
      children: [
        const ChallengeTemplatesStrip(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildChallengesList(
                context,
                state.activeChallenges,
                title: ServerChallengeStrings.emptyActive,
                subtitle: ServerChallengeStrings.emptyActiveSubtitle,
                icon: Icons.emoji_events_outlined,
                showCreateCta: true,
              ),
              _buildChallengesList(
                context,
                state.upcomingChallenges,
                title: ServerChallengeStrings.emptyUpcoming,
                subtitle: ServerChallengeStrings.emptyUpcomingSubtitle,
                icon: Icons.schedule_rounded,
              ),
              _buildChallengesList(
                context,
                state.completedChallenges,
                title: ServerChallengeStrings.emptyCompleted,
                subtitle: ServerChallengeStrings.emptyCompletedSubtitle,
                icon: Icons.check_circle_outline_rounded,
              ),
              _buildChallengesList(
                context,
                state.expiredChallenges,
                title: ServerChallengeStrings.emptyExpired,
                subtitle: ServerChallengeStrings.emptyExpiredSubtitle,
                icon: Icons.history_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesList(
    BuildContext context,
    List challenges, {
    required String title,
    required String subtitle,
    required IconData icon,
    bool showCreateCta = false,
  }) {
    Future<void> onRefresh() =>
        ref.read(challengesProvider.notifier).refreshChallenges();

    if (challenges.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 24),
            IOSEmptyState(
              icon: icon,
              title: title,
              subtitle: subtitle,
              buttonLabel:
                  showCreateCta ? ServerChallengeStrings.createTitle : null,
              onPressed: showCreateCta
                  ? () => _navigateToCreateChallenge(context)
                  : null,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppLayout.pageGutter),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          return AppAnimatedListItem(
            index: index,
            child: ChallengeCard(challenge: challenges[index]),
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    final lower = message.toLowerCase();
    final isServerError = lower.contains('server') ||
        lower.contains('500') ||
        lower.contains('خادم') ||
        lower.contains('unavailable');

    return Center(
      child: IOSEmptyState(
        icon: isServerError
            ? Icons.cloud_off_rounded
            : Icons.error_outline_rounded,
        title: message,
        subtitle: isServerError ? ServerChallengeStrings.serverMaintenanceHint : '',
        iconColor: Theme.of(context).colorScheme.error,
        buttonLabel: ServerChallengeStrings.retry,
        onPressed: () =>
            ref.read(challengesProvider.notifier).loadChallenges(),
      ),
    );
  }

  void _navigateToCreateChallenge(BuildContext context) {
    context.push(AppRoutes.challengesCreate);
  }

  void _navigateToPendingInvitations(BuildContext context) {
    context.push(AppRoutes.challengesInvitations);
  }
}
