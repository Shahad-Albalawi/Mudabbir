import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/haptic_service.dart';

class SummaryWidget extends ConsumerStatefulWidget {
  const SummaryWidget({super.key});

  @override
  ConsumerState<SummaryWidget> createState() => _SummaryWidgetState();
}

class _SummaryWidgetState extends ConsumerState<SummaryWidget>
    with SingleTickerProviderStateMixin {
  bool showTotal = false; // default = this month
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Formats amount for display (e.g. 1,234.56 ر.س).
  String _formatAmount(num value) {
    return '${value.toStringAsFixed(2)} ر.س';
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final scheme = Theme.of(context).colorScheme;
    final gradientEnd =
        Color.lerp(scheme.primary, scheme.onPrimary, 0.28) ?? scheme.primary;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, gradientEnd],
            stops: const [0.0, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.onPrimary.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.financialStatus,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        showTotal ? AppStrings.allTime : AppStrings.thisMonth,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          HapticService.selection();
                          setState(() {
                            showTotal = !showTotal;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  showTotal
                                      ? Icons.calendar_view_month
                                      : Icons.calendar_today,
                                  key: ValueKey(showTotal),
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                showTotal
                                    ? AppStrings.totalLabel
                                    : AppStrings.currentMonthLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Financial Data Cards
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: Column(
                  key: ValueKey(showTotal),
                  children: [
                    // Income Card
                    _buildFinancialCard(
                      context: context,
                      icon: Icons.trending_up_rounded,
                      iconColor: ColorManager.success,
                      label: AppStrings.totalIncome,
                      amount: _formatAmount(showTotal
                          ? homeState.totalIncome
                          : homeState.monthlyIncome),
                      isPositive: true,
                    ),
                    const SizedBox(height: 12),

                    // Balance Card
                    _buildFinancialCard(
                      context: context,
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: scheme.primary,
                      label: AppStrings.currentBalance,
                      amount: _formatAmount(showTotal
                          ? homeState.currentBalance
                          : homeState.monthlyBalance),
                      isBalance: true,
                    ),
                    const SizedBox(height: 12),

                    // Expense Card
                    _buildFinancialCard(
                      context: context,
                      icon: Icons.trending_down_rounded,
                      iconColor: ColorManager.error,
                      label: AppStrings.totalExpense,
                      amount: _formatAmount(showTotal
                          ? homeState.totalExpense
                          : homeState.monthlyExpense),
                      isPositive: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildHealthScoreAndAlerts(homeState),
              const SizedBox(height: 8),
              _buildBudgetAutopilot(homeState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String amount,
    bool isPositive = true,
    bool isBalance = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isBalance
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : isPositive
                  ? ColorManager.success.withValues(alpha: 0.2)
                  : ColorManager.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isBalance
                  ? Icons.account_balance
                  : isPositive
                  ? Icons.add
                  : Icons.remove,
              color: isBalance
                  ? Theme.of(context).colorScheme.primary
                  : isPositive
                  ? ColorManager.success
                  : ColorManager.error,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScoreAndAlerts(HomeState homeState) {
    final score = homeState.financialHealthScore;
    final scoreColor = score >= 75
        ? ColorManager.success
        : score >= 50
        ? const Color(0xFFFFB020)
        : ColorManager.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: Row(
            children: [
              Icon(Icons.health_and_safety_rounded, color: scoreColor, size: 18),
              const SizedBox(width: 8),
              Text(
                '${AppStrings.financialHealth}: $score/100',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (homeState.spendingAlerts.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final alert in homeState.spendingAlerts)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      alert,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildBudgetAutopilot(HomeState homeState) {
    if (homeState.nextMonthBudgetSuggestion <= 0) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${AppStrings.nextMonthBudgetSuggestion}: ${homeState.nextMonthBudgetSuggestion.toStringAsFixed(0)} ﷼',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
