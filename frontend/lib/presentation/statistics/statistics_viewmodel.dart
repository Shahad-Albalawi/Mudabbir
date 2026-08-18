import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/remote/analytics_api_service.dart';
import 'package:mudabbir/domain/services/financial_aggregator.dart';
import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/utils/api_session.dart';

class StatisticsState {
  final double totalIncome;
  final double totalExpense;
  final double currentBalance;
  final Map<String, double> expenseByCategory;
  final Map<String, double> incomeByCategory;
  final Map<String, double> accountsBalance;
  final Map<String, double> goalsProgress;
  final Map<String, double> budgetsProgress;
  final bool isLoading;
  final String? errorMessage;

  const StatisticsState({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.currentBalance = 0,
    this.expenseByCategory = const {},
    this.incomeByCategory = const {},
    this.accountsBalance = const {},
    this.goalsProgress = const {},
    this.budgetsProgress = const {},
    this.isLoading = true,
    this.errorMessage,
  });

  bool get hasMeaningfulData =>
      totalIncome != 0 ||
      totalExpense != 0 ||
      expenseByCategory.isNotEmpty ||
      incomeByCategory.isNotEmpty ||
      goalsProgress.isNotEmpty ||
      budgetsProgress.isNotEmpty;

  /// Fingerprint for skipping redundant analysis rebuilds.
  int get analysisFingerprint => Object.hash(
        totalIncome,
        totalExpense,
        expenseByCategory.length,
        incomeByCategory.length,
        goalsProgress.length,
        budgetsProgress.length,
        Object.hashAll(expenseByCategory.entries.take(12)),
        Object.hashAll(goalsProgress.entries.take(12)),
      );

  StatisticsState copyWith({
    double? totalIncome,
    double? totalExpense,
    double? currentBalance,
    Map<String, double>? expenseByCategory,
    Map<String, double>? incomeByCategory,
    Map<String, double>? accountsBalance,
    Map<String, double>? goalsProgress,
    Map<String, double>? budgetsProgress,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StatisticsState(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      currentBalance: currentBalance ?? this.currentBalance,
      expenseByCategory: expenseByCategory ?? this.expenseByCategory,
      incomeByCategory: incomeByCategory ?? this.incomeByCategory,
      accountsBalance: accountsBalance ?? this.accountsBalance,
      goalsProgress: goalsProgress ?? this.goalsProgress,
      budgetsProgress: budgetsProgress ?? this.budgetsProgress,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final statisticsProvider =
    StateNotifierProvider<StatisticsViewModel, StatisticsState>((ref) {
  ref.keepAlive();
  return StatisticsViewModel(
    db: ref.watch(dbHelperProvider),
    analyticsApi: ref.watch(analyticsApiServiceProvider),
  );
});

class StatisticsViewModel extends StateNotifier<StatisticsState> {
  StatisticsViewModel({
    required DbHelper db,
    required AnalyticsApiService analyticsApi,
  })  : _dbHelper = db,
        _aggregator = FinancialAggregator(db: db),
        _analyticsApi = analyticsApi,
        super(const StatisticsState()) {
    loadStatistics();
  }

  final DbHelper _dbHelper;
  final FinancialAggregator _aggregator;
  final AnalyticsApiService _analyticsApi;

  int? _cachedFingerprint;
  StatisticsState? _cachedSnapshot;

  Future<void> loadStatistics({bool force = false}) async {
    if (!force &&
        !state.isLoading &&
        state.errorMessage == null &&
        _cachedSnapshot != null &&
        _cachedFingerprint == state.analysisFingerprint) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      if (await hasApiSession()) {
        try {
          final apiData = await _analyticsApi.getStatistics();
          final mapped = ApiStatisticsMapper.fromApi(apiData);
          final accs = await _aggregator.balancesPerAccount();
          final next = state.copyWith(
            totalIncome: mapped.totalIncome,
            totalExpense: mapped.totalExpense,
            currentBalance: mapped.currentBalance,
            expenseByCategory: mapped.expenseByCategory,
            incomeByCategory: mapped.incomeByCategory,
            accountsBalance: accs,
            goalsProgress: mapped.goalsProgress,
            budgetsProgress: mapped.budgetsProgress,
            isLoading: false,
            clearError: true,
          );
          _cachedSnapshot = next;
          _cachedFingerprint = next.analysisFingerprint;
          state = next;
          return;
        } catch (_) {
          // Fall back to local SQLite aggregates when offline or API error.
        }
      }

      final totalsFuture = _aggregator.incomeAndExpenseTotals();
      final expByCatFuture = _categoryTotals('expense');
      final incByCatFuture = _categoryTotals('income');
      final accsFuture = _aggregator.balancesPerAccount();
      final goalsFuture = _loadGoalsProgress();
      final budgetsFuture = _loadBudgetsProgress();

      final results = await Future.wait([
        totalsFuture,
        expByCatFuture,
        incByCatFuture,
        accsFuture,
        goalsFuture,
        budgetsFuture,
      ]);

      final totals = results[0] as ({double income, double expense});
      final expByCat = results[1] as Map<String, double>;
      final incByCat = results[2] as Map<String, double>;
      final accs = results[3] as Map<String, double>;
      final goals = results[4] as Map<String, double>;
      final budgets = results[5] as Map<String, double>;

      final next = state.copyWith(
        totalIncome: totals.income,
        totalExpense: totals.expense,
        currentBalance: totals.income - totals.expense,
        expenseByCategory: expByCat,
        incomeByCategory: incByCat,
        accountsBalance: accs,
        goalsProgress: goals,
        budgetsProgress: budgets,
        isLoading: false,
        clearError: true,
      );

      _cachedSnapshot = next;
      _cachedFingerprint = next.analysisFingerprint;
      state = next;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.statsScreenLoadFailed,
      );
    }
  }

  Future<Map<String, double>> _categoryTotals(String type) async {
    final result = await _dbHelper.complexQuery(
      table: 'transactions t',
      columns: [
        "COALESCE(c.name, 'Uncategorized') as category",
        'SUM(t.amount) as total',
      ],
      joinClause: 'LEFT JOIN categories c ON t.category_id = c.id',
      where: 't.type = ?',
      whereArgs: [type],
      groupBy: 'category',
    );
    return result.fold(
      (_) => <String, double>{},
      (rows) => {
        for (final r in rows)
          r['category'] as String: (r['total'] as num).toDouble(),
      },
    );
  }

  Future<Map<String, double>> _loadGoalsProgress() async {
    final goalsResult = await _dbHelper.queryAllRows('goals');
    return goalsResult.fold(
      (_) => <String, double>{},
      (rows) => {
        for (final r in rows)
          r['name'] as String: _goalProgressPercent(
            (r['current_amount'] as num).toDouble(),
            (r['target'] as num).toDouble(),
          ),
      },
    );
  }

  Future<Map<String, double>> _loadBudgetsProgress() async {
    final spentById = await _aggregator.spentAmountPerBudget();
    final budgetResult = await _dbHelper.queryAllRows('budgets');
    return budgetResult.fold(
      (_) => <String, double>{},
      (rows) {
        final budgets = <String, double>{};
        for (final r in rows) {
          final id = (r['id'] as num).toInt();
          final amount = (r['amount'] as num).toDouble();
          final spent = spentById[id] ?? 0.0;
          budgets['Budget #$id'] =
              amount <= 0 ? 0 : ((spent / amount) * 100).clamp(0, 999);
        }
        return budgets;
      },
    );
  }

  static double _goalProgressPercent(double current, double target) {
    if (target <= 0) return 0;
    return ((current / target) * 100).clamp(0, 100);
  }
}
