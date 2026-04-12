import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/resources/styles_manager.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_state.dart';
import 'package:mudabbir/presentation/server_challenges/screens/create_challenge_screen.dart';
import 'package:mudabbir/presentation/server_challenges/widgets/challenge_card.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/presentation/server_challenges/screens/pending_invitations_screen.dart';

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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ColorManager.primary,
              ColorManager.primary.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildTabBar(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _buildBody(challengeState),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateChallenge(context),
        icon: const Icon(Icons.add),
        label: Text(ServerChallengeStrings.newChallengeFab),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    // Watch pending invitations count
    final pendingState = ref.watch(pendingInvitationsProvider);
    int pendingCount = 0;
    if (pendingState is ChallengeLoaded) {
      pendingCount = pendingState.challenges.length;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            ServerChallengeStrings.listTitle,
            style: getBoldStyle(fontSize: FontSize.s24, color: Colors.white),
          ),
          const Spacer(),
          // Pending invitations button
          Stack(
            children: [
              IconButton(
                onPressed: () => _navigateToPendingInvitations(context),
                icon: const Icon(Icons.notifications, color: Colors.white),
              ),
              if (pendingCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ColorManager.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$pendingCount',
                      style: const TextStyle(
                        color: Colors.white,
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
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        labelColor: ColorManager.primary,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
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
      ChallengeLoading() => const Center(child: CircularProgressIndicator()),
      ChallengeError(:final message) => _buildError(message),
      ChallengeLoaded() => _buildTabBarView(state),
    };
  }

  Widget _buildTabBarView(ChallengeLoaded state) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildChallengesList(
          state.activeChallenges,
          ServerChallengeStrings.emptyActive,
        ),
        _buildChallengesList(
          state.upcomingChallenges,
          ServerChallengeStrings.emptyUpcoming,
        ),
        _buildChallengesList(
          state.completedChallenges,
          ServerChallengeStrings.emptyCompleted,
        ),
        _buildChallengesList(
          state.expiredChallenges,
          ServerChallengeStrings.emptyExpired,
        ),
      ],
    );
  }

  Widget _buildChallengesList(List challenges, String emptyMessage) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: ColorManager.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: getMediumStyle(
                fontSize: FontSize.s16,
                color: ColorManager.grey1,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(challengesProvider.notifier).refreshChallenges(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          return ChallengeCard(challenge: challenges[index]);
        },
      ),
    );
  }

  Widget _buildError(String message) {
    final lower = message.toLowerCase();
    final isServerError =
        lower.contains('server') ||
        lower.contains('500') ||
        lower.contains('خادم') ||
        lower.contains('unavailable');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ColorManager.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isServerError
                    ? Icons.cloud_off_rounded
                    : Icons.error_outline_rounded,
                size: 64,
                color: ColorManager.error.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: getMediumStyle(
                fontSize: FontSize.s16,
                color: ColorManager.darkGrey,
              ),
              textDirection: AppStrings.isEnglishLocale
                  ? TextDirection.ltr
                  : TextDirection.rtl,
            ),
            if (isServerError) ...[
              const SizedBox(height: 12),
              Text(
                ServerChallengeStrings.serverMaintenanceHint,
                textAlign: TextAlign.center,
                style: getRegularStyle(
                  fontSize: FontSize.s14,
                  color: ColorManager.grey1,
                ),
                textDirection: AppStrings.isEnglishLocale
                    ? TextDirection.ltr
                    : TextDirection.rtl,
              ),
            ],
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(challengesProvider.notifier).loadChallenges(),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(ServerChallengeStrings.retry),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateChallenge(BuildContext context) {
    getIt<NavigationService>().navigate(const CreateChallengeScreen());
  }

  void _navigateToPendingInvitations(BuildContext context) {
    getIt<NavigationService>().navigate(const PendingInvitationsScreen());
  }
}
