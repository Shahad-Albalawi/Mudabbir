import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/local_database.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/domain/repository/home_repository/home_repository.dart';
import 'package:mudabbir/domain/models/savings_goal.dart';
import 'package:mudabbir/domain/repository/synced_expense_repository/synced_expense_repository.dart';
import 'package:mudabbir/domain/repository/synced_goals_repository/synced_goals_repository.dart';
import 'package:mudabbir/domain/services/financial_date_utils.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/utils/local_db_user_id.dart';
import 'package:mudabbir/utils/user_display_name.dart';

class HomeBudgetCategoryRow {
  const HomeBudgetCategoryRow({
    required this.name,
    required this.emoji,
    required this.colorValue,
    required this.spent,
    required this.limit,
  });

  final String name;
  final String emoji;
  final int colorValue;
  final double spent;
  final double limit;

  double get progress =>
      limit <= 0 ? 0 : (spent / limit).clamp(0.0, 1.0);
}

class HomeMonthlyBudget {
  const HomeMonthlyBudget({
    this.limit = 0,
    this.spent = 0,
  });

  final double limit;
  final double spent;

  double get usedPercent =>
      limit <= 0 ? 0 : ((spent / limit) * 100).clamp(0, 150);

  bool get hasBudget => limit > 0;
}

/// Lightweight goal row for the home dashboard.
class HomeGoalSnapshot {
  const HomeGoalSnapshot({
    required this.id,
    required this.name,
    required this.progressPercent,
    required this.currentAmount,
    required this.target,
    required this.isCompleted,
  });

  final int id;
  final String name;
  final double progressPercent;
  final double currentAmount;
  final double target;
  final bool isCompleted;

  factory HomeGoalSnapshot.fromGoal(SavingsGoal goal) {
    return HomeGoalSnapshot(
      id: goal.id,
      name: goal.name,
      progressPercent: goal.progressPercent,
      currentAmount: goal.currentAmount,
      target: goal.target,
      isCompleted: goal.isCompleted,
    );
  }
}

class HomeScreenState {
  const HomeScreenState({
    this.isLoading = true,
    this.errorMessage,
    this.userName = '',
    this.balance = 0,
    this.monthChangePercent = 0,
    this.balanceVisible = true,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
    this.financialHealthScore = 0,
    this.spendingAlerts = const [],
    this.nextMonthBudgetSuggestion = 0,
    this.goalSnapshots = const [],
    this.recentTransactions = const [],
    this.monthlyBudget = const HomeMonthlyBudget(),
    this.budgetCategories = const [],
    this.loadedAt,
    this.animatingTransactionId,
  });

  final bool isLoading;
  final String? errorMessage;
  final String userName;
  final double balance;
  final double monthChangePercent;
  final bool balanceVisible;
  final double monthlyIncome;
  final double monthlyExpense;
  final int financialHealthScore;
  final List<String> spendingAlerts;
  final double nextMonthBudgetSuggestion;
  final List<HomeGoalSnapshot> goalSnapshots;
  final List<ExpenseTransaction> recentTransactions;
  final HomeMonthlyBudget monthlyBudget;
  final List<HomeBudgetCategoryRow> budgetCategories;
  final DateTime? loadedAt;
  final int? animatingTransactionId;

  bool get monthChangePositive => monthChangePercent >= 0;

  HomeScreenState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? userName,
    double? balance,
    double? monthChangePercent,
    bool? balanceVisible,
    double? monthlyIncome,
    double? monthlyExpense,
    int? financialHealthScore,
    List<String>? spendingAlerts,
    double? nextMonthBudgetSuggestion,
    List<HomeGoalSnapshot>? goalSnapshots,
    List<ExpenseTransaction>? recentTransactions,
    HomeMonthlyBudget? monthlyBudget,
    List<HomeBudgetCategoryRow>? budgetCategories,
    DateTime? loadedAt,
    int? animatingTransactionId,
    bool clearAnimatingTransactionId = false,
  }) {
    return HomeScreenState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      userName: userName ?? this.userName,
      balance: balance ?? this.balance,
      monthChangePercent: monthChangePercent ?? this.monthChangePercent,
      balanceVisible: balanceVisible ?? this.balanceVisible,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpense: monthlyExpense ?? this.monthlyExpense,
      financialHealthScore: financialHealthScore ?? this.financialHealthScore,
      spendingAlerts: spendingAlerts ?? this.spendingAlerts,
      nextMonthBudgetSuggestion:
          nextMonthBudgetSuggestion ?? this.nextMonthBudgetSuggestion,
      goalSnapshots: goalSnapshots ?? this.goalSnapshots,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      budgetCategories: budgetCategories ?? this.budgetCategories,
      loadedAt: loadedAt ?? this.loadedAt,
      animatingTransactionId: clearAnimatingTransactionId
          ? null
          : (animatingTransactionId ?? this.animatingTransactionId),
    );
  }
}

final homeScreenProvider =
    StateNotifierProvider<HomeScreenNotifier, HomeScreenState>(
  (ref) => HomeScreenNotifier(ref),
);

class HomeScreenNotifier extends StateNotifier<HomeScreenState> {
  HomeScreenNotifier(this._ref) : super(const HomeScreenState()) {
    load();
  }

  /// Seeds dashboard state without triggering [load] — for widget tests only.
  @visibleForTesting
  HomeScreenNotifier.preview(this._ref, HomeScreenState initial)
      : super(initial);

  final Ref _ref;
  final DbHelper _db = getIt<DbHelper>();
  final HomeRepository _homeRepository = getIt<HomeRepository>();
  final SyncedExpenseRepository _expenseRepository =
      getIt<SyncedExpenseRepository>();
  final SyncedGoalsRepository _goalsRepository =
      getIt<SyncedGoalsRepository>();

  Future<void> load({bool force = false}) async {
    if (!force && !state.isLoading && state.errorMessage == null) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await getIt<HiveService>().getValue(
        HiveConstants.savedUserInfo,
      );
      final userName = UserDisplayName.fromSavedUserInfo(user);
      await LocalDatabase.instance.initForUser(resolveLocalDbUserId(user));

      await _ref.read(homeProvider.notifier).reload();
      final home = _ref.read(homeProvider);

      final now = DateTime.now();
      final prevAnchor = DateTime(now.year, now.month - 1, 1);
      final previousMonth = FinancialDateUtils.monthRange(prevAnchor);

      final prevIncome = await _homeRepository.getTotalIncome(
        startDate: previousMonth.start,
        endDate: previousMonth.end,
      );
      final prevExpense = await _homeRepository.getTotalExpense(
        startDate: previousMonth.start,
        endDate: previousMonth.end,
      );
      final prevNet = prevIncome - prevExpense;
      final currentNet = home.monthlyIncome - home.monthlyExpense;
      final monthChange = prevNet == 0
          ? (currentNet == 0 ? 0.0 : 100.0)
          : ((currentNet - prevNet) / prevNet.abs()) * 100;

      final recent = await _loadRecentTransactions();
      final budget = await _loadMonthlyBudget(spent: home.monthlyExpense);
      final categories = await _loadBudgetCategories(
        spent: home.monthlyExpense,
        monthlyLimit: budget.limit,
      );
      final goals = await _loadGoalSnapshots();

      state = state.copyWith(
        isLoading: false,
        userName: userName,
        balance: home.currentBalance,
        monthChangePercent: monthChange,
        monthlyIncome: home.monthlyIncome,
        monthlyExpense: home.monthlyExpense,
        financialHealthScore: home.financialHealthScore,
        spendingAlerts: home.spendingAlerts,
        nextMonthBudgetSuggestion: home.nextMonthBudgetSuggestion,
        goalSnapshots: goals,
        recentTransactions: recent,
        monthlyBudget: budget,
        budgetCategories: categories,
        loadedAt: DateTime.now(),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.statsHomeLoadFailed,
      );
    }
  }

  Future<bool> deleteTransaction(int id) async {
    final result = await _expenseRepository.deleteTransaction(id);
    return result.fold(
      (_) => false,
      (sync) {
        if (sync.deleted) {
          load(force: true);
          _ref.read(homeProvider.notifier).reload();
        }
        return sync.deleted;
      },
    );
  }

  /// Inserts a saved transaction at the top of the home list with enter animation.
  void prependTransaction(ExpenseTransaction transaction) {
    final isIncome = transaction.type == 'income';
    final isCurrentMonth = _isCurrentMonth(transaction.date);
    final filtered = state.recentTransactions
        .where((t) => t.id != transaction.id)
        .toList();
    final updated = [transaction, ...filtered].take(5).toList();

    state = state.copyWith(
      recentTransactions: updated,
      balance: state.balance + (isIncome ? transaction.amount : -transaction.amount),
      monthlyIncome: isCurrentMonth && isIncome
          ? state.monthlyIncome + transaction.amount
          : state.monthlyIncome,
      monthlyExpense: isCurrentMonth && !isIncome
          ? state.monthlyExpense + transaction.amount
          : state.monthlyExpense,
      animatingTransactionId: transaction.id,
      loadedAt: DateTime.now(),
    );
  }

  void clearTransactionAnimation() {
    if (state.animatingTransactionId != null) {
      state = state.copyWith(clearAnimatingTransactionId: true);
    }
  }

  bool _isCurrentMonth(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return true;
    final now = DateTime.now();
    return parsed.year == now.year && parsed.month == now.month;
  }

  Future<List<ExpenseTransaction>> _loadRecentTransactions() async {
    final result = await _db.complexQuery(
      table: 'transactions t',
      columns: [
        't.id',
        't.amount',
        't.date',
        't.type',
        't.notes',
        't.account_id',
        't.category_id',
        't.is_recurring',
        't.recurrence_interval',
        't.updated_at',
        'a.name AS account_name',
        'c.name AS category_name',
      ],
      joinClause:
          'LEFT JOIN accounts a ON a.id = t.account_id LEFT JOIN categories c ON c.id = t.category_id',
      orderBy: 't.date DESC, t.id DESC',
      limit: 5,
    );

    return result.fold(
      (_) => <ExpenseTransaction>[],
      (rows) => rows.map(ExpenseTransaction.fromMap).toList(),
    );
  }

  Future<List<HomeGoalSnapshot>> _loadGoalSnapshots() async {
    try {
      final result = await _goalsRepository.getGoals();
      final active = result.goals
          .where((g) => !g.isCompleted)
          .map(HomeGoalSnapshot.fromGoal)
          .toList();
      active.sort((a, b) => b.progressPercent.compareTo(a.progressPercent));
      return active.take(3).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<HomeMonthlyBudget> _loadMonthlyBudget({required double spent}) async {
    final today = FinancialDateUtils.isoDate(DateTime.now());
    final result = await _db.complexQuery(
      table: 'budgets',
      columns: ['amount', 'start_date', 'end_date'],
      where: 'date(?) BETWEEN date(start_date) AND date(end_date)',
      whereArgs: [today],
    );

    return result.fold(
      (_) => HomeMonthlyBudget(spent: spent),
      (rows) {
        if (rows.isEmpty) {
          return HomeMonthlyBudget(spent: spent);
        }
        final limit = rows.fold<double>(
          0,
          (sum, row) => sum + ((row['amount'] as num?)?.toDouble() ?? 0),
        );
        return HomeMonthlyBudget(limit: limit, spent: spent);
      },
    );
  }

  Future<List<HomeBudgetCategoryRow>> _loadBudgetCategories({
    required double spent,
    required double monthlyLimit,
  }) async {
    final month = FinancialDateUtils.monthRange(DateTime.now());
    final result = await _db.complexQuery(
      table: 'transactions t',
      columns: [
        'c.name AS category_name',
        'SUM(t.amount) AS total',
      ],
      joinClause: 'LEFT JOIN categories c ON c.id = t.category_id',
      where:
          "t.type = 'expense' AND date(t.date) BETWEEN date(?) AND date(?)",
      whereArgs: [
        month.start,
        month.end,
      ],
      groupBy: 't.category_id',
      orderBy: 'total DESC',
      limit: 2,
    );

    return result.fold(
      (_) => const [],
      (rows) {
        if (rows.isEmpty) return const [];
        final perCategoryLimit = monthlyLimit > 0 && rows.isNotEmpty
            ? monthlyLimit / rows.length
            : 0.0;
        return rows.map((row) {
          final name = (row['category_name'] as String?) ?? 'أخرى';
          final total = (row['total'] as num?)?.toDouble() ?? 0;
          final limit = perCategoryLimit > 0
              ? perCategoryLimit
              : (total * 1.25).clamp(100.0, double.infinity).toDouble();
          return HomeBudgetCategoryRow(
            name: name,
            emoji: _emojiForCategory(name),
            colorValue: name.hashCode,
            spent: total,
            limit: limit,
          );
        }).toList();
      },
    );
  }

  static String _emojiForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('تسوق') || n.contains('shop')) return '🛒';
    if (n.contains('مواصلات') || n.contains('transport')) return '🚗';
    if (n.contains('طعام') || n.contains('food')) return '🍽️';
    return '📂';
  }
}
