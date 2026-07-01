import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/presentation/home/home_screen_provider.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/core/widgets/balance_card.dart';
import 'package:mudabbir/presentation/home/widgets/home_budget_section.dart';
import 'package:mudabbir/presentation/home/widgets/home_quick_actions.dart';
import 'package:mudabbir/presentation/home/widgets/home_sync_banner.dart';
import 'package:mudabbir/presentation/home/widgets/home_top_bar.dart';
import 'package:mudabbir/presentation/notifications/notifications_provider.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/app_confirm_dialog.dart';
import 'package:mudabbir/presentation/widgets/riyal_amount.dart';
import 'package:mudabbir/presentation/widgets/section_title_text.dart';
import 'package:mudabbir/presentation/widgets/score_ring_widget.dart';
import 'package:mudabbir/presentation/widgets/transaction_tile.dart';
import 'package:mudabbir/service/financial_refresh.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

/// Premium home dashboard for مُدَبِّر.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

const _kHomeSectionGap = 24.0;

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _sectionGap = _kHomeSectionGap;

  Future<void> _refresh() async {
    await FinancialRefresh.refreshAll(ref);
    await ref.read(homeScreenProvider.notifier).load(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeScreenProvider);
    final colors = context.colors;
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    if (state.isLoading && state.recentTransactions.isEmpty) {
      return ColoredBox(
        color: colors.background,
        child: _HomeShimmer(colors: colors),
      );
    }

    final recent = state.recentTransactions.take(3).toList();

    return ColoredBox(
      color: colors.background,
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: colors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: HomeTopBar(
                userName: state.userName,
                notificationBadgeCount: unreadCount,
              ),
            ),
            const SliverToBoxAdapter(child: HomeSyncBanner()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppLayout.bottomNavClearance,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (state.errorMessage != null) ...[
                    _ErrorBanner(
                      message: state.errorMessage!,
                      onRetry: _refresh,
                    ),
                    const SizedBox(height: _sectionGap),
                  ],
                  BalanceCard(
                    balance: state.balance,
                    income: state.monthlyIncome,
                    expenses: state.monthlyExpense,
                    lastUpdated: state.loadedAt,
                  ),
                  const SizedBox(height: _sectionGap),
                  const HomeQuickActions(),
                  const SizedBox(height: _sectionGap),
                  _FinancialHealthCard(
                    score: state.financialHealthScore,
                    onDetails: () => context.push(AppRoutes.financialHealth),
                  ),
                  const SizedBox(height: _sectionGap),
                  HomeBudgetSection(categories: state.budgetCategories),
                  if (state.goalSnapshots.isNotEmpty) ...[
                    const SizedBox(height: _sectionGap),
                    _SectionHeader(
                      title: AppStrings.homeActiveGoals,
                      trailingLabel: AppStrings.homeViewAll,
                      onTrailing: () {
                        HapticService.light();
                        ref.read(homeProvider.notifier).changeNavBar(2);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _GoalsCarousel(goals: state.goalSnapshots),
                  ],
                  const SizedBox(height: _sectionGap),
                  _SectionHeader(
                    title: AppStrings.homeRecentTransactions,
                    trailingLabel: AppStrings.homeViewAll,
                    onTrailing: () => context.push(AppRoutes.expenses),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _RecentTransactionsSection(
                    transactions: recent,
                    animatingTransactionId: state.animatingTransactionId,
                    onDelete: (id) async {
                      final confirmed = await AppConfirmDialog.show(
                        context,
                        title: AppStrings.expenseDeleteConfirmTitle,
                        message: AppStrings.expenseDeleteConfirmBody,
                        confirmLabel: AppStrings.delete,
                      );
                      if (!confirmed || !context.mounted) return false;
                      return ref
                          .read(homeScreenProvider.notifier)
                          .deleteTransaction(id);
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error banner
// ---------------------------------------------------------------------------

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.expense.withValues(alpha: 0.06),
      bordered: true,
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.expense),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium(AppColors.gray600),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              AppStrings.retry,
              style: AppTypography.labelLarge(AppColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.trailingLabel,
    required this.onTrailing,
  });

  final String title;
  final String trailingLabel;
  final VoidCallback onTrailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: SectionTitleText(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        TextButton(
          onPressed: onTrailing,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            trailingLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Financial health
// ---------------------------------------------------------------------------

class _FinancialHealthCard extends StatelessWidget {
  const _FinancialHealthCard({
    required this.score,
    required this.onDetails,
  });

  final int score;
  final VoidCallback onDetails;

  String _chipLabel(int score) => AppStrings.healthScoreLabel(score);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final chipColor = score >= 60 ? colors.green : colors.gold;
    final chipBg = score >= 60 ? colors.greenSurface : colors.goldSurface;

    return Material(
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.border, width: 0.5),
      ),
      child: InkWell(
        onTap: onDetails,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Row(
            children: [
              ScoreRingWidget(
                score: score,
                color: colors.primary,
                size: 50,
                strokeWidth: 5,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitleText(
                      AppStrings.financialHealth,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.homeFinancialHealthSubtitle,
                      textAlign: TextAlign.start,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        _chipLabel(score),
                        style: textTheme.labelMedium?.copyWith(
                          color: chipColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: colors.textTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Goals carousel
// ---------------------------------------------------------------------------

class _GoalsCarousel extends StatelessWidget {
  const _GoalsCarousel({required this.goals});

  final List<HomeGoalSnapshot> goals;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: goals.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) => _GoalCard(goal: goals[index]),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final HomeGoalSnapshot goal;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final progress = (goal.progressPercent / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: 160,
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.goldSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.savings_outlined, size: 18, color: colors.gold),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              goal.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                color: colors.primary,
                backgroundColor: colors.primarySurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${goal.progressPercent.toStringAsFixed(0)}%',
              style: textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            RiyalAmount(
              goal.currentAmount,
              fontSize: 12,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recent transactions
// ---------------------------------------------------------------------------

class _RecentTransactionsSection extends ConsumerStatefulWidget {
  const _RecentTransactionsSection({
    required this.transactions,
    required this.animatingTransactionId,
    required this.onDelete,
  });

  final List<ExpenseTransaction> transactions;
  final int? animatingTransactionId;
  final Future<bool> Function(int id) onDelete;

  @override
  ConsumerState<_RecentTransactionsSection> createState() =>
      _RecentTransactionsSectionState();
}

class _RecentTransactionsSectionState
    extends ConsumerState<_RecentTransactionsSection> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    if (widget.transactions.isEmpty) {
      return AppCard(
        margin: EdgeInsets.zero,
        child: Text(
          AppStrings.expensesEmptyTitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
      );
    }

    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < widget.transactions.length; i++)
            _AnimatedTransactionTile(
              key: ValueKey(widget.transactions[i].id),
              transaction: widget.transactions[i],
              animate: widget.transactions[i].id ==
                  widget.animatingTransactionId,
              onDelete: widget.onDelete,
              showDivider: i > 0,
              onAnimationEnd: () {
                ref.read(homeScreenProvider.notifier).clearTransactionAnimation();
              },
            ),
        ],
      ),
    );
  }
}

class _AnimatedTransactionTile extends StatefulWidget {
  const _AnimatedTransactionTile({
    super.key,
    required this.transaction,
    required this.animate,
    required this.onDelete,
    required this.showDivider,
    required this.onAnimationEnd,
  });

  final ExpenseTransaction transaction;
  final bool animate;
  final Future<bool> Function(int id) onDelete;
  final bool showDivider;
  final VoidCallback onAnimationEnd;

  @override
  State<_AnimatedTransactionTile> createState() =>
      _AnimatedTransactionTileState();
}

class _AnimatedTransactionTileState extends State<_AnimatedTransactionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.animate) {
      _controller.forward().then((_) => widget.onAnimationEnd());
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: TransactionTile(
          transaction: widget.transaction,
          onDelete: widget.onDelete,
          showDivider: widget.showDivider,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer
// ---------------------------------------------------------------------------

class _HomeShimmer extends StatefulWidget {
  const _HomeShimmer({required this.colors});

  final AppColorScheme colors;

  @override
  State<_HomeShimmer> createState() => _HomeShimmerState();
}

class _HomeShimmerState extends State<_HomeShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppLayout.bottomNavClearance,
      ),
      children: [
        _ShimmerBox(
          controller: _controller,
          height: 56,
          baseColor: widget.colors.border,
          highlightColor: widget.colors.surface,
        ),
        const SizedBox(height: AppSpacing.md),
        _ShimmerBox(
          controller: _controller,
          height: 200,
          radius: AppRadius.cardHero,
          baseColor: widget.colors.border,
          highlightColor: widget.colors.surface,
        ),
        const SizedBox(height: _kHomeSectionGap),
        _ShimmerBox(
          controller: _controller,
          height: 72,
          baseColor: widget.colors.border,
          highlightColor: widget.colors.surface,
        ),
        const SizedBox(height: _kHomeSectionGap),
        _ShimmerBox(
          controller: _controller,
          height: 140,
          radius: AppRadius.card,
          baseColor: widget.colors.border,
          highlightColor: widget.colors.surface,
        ),
      ],
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.controller,
    required this.height,
    required this.baseColor,
    required this.highlightColor,
    this.radius = AppRadius.sm,
  });

  final AnimationController controller;
  final double height;
  final Color baseColor;
  final Color highlightColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * controller.value, 0),
              end: Alignment(1 + 2 * controller.value, 0),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}
