import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/domain/services/financial_aggregator.dart';
import 'package:mudabbir/service/getit_init.dart';

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

  StatisticsState({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.currentBalance = 0,
    this.expenseByCategory = const {},
    this.incomeByCategory = const {},
    this.accountsBalance = const {},
    this.goalsProgress = const {},
    this.budgetsProgress = const {},
    this.isLoading = false,
    this.errorMessage,
  });

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
      errorMessage: errorMessage,
    );
  }
}

final statisticsProvider =
    StateNotifierProvider<StatisticsViewModel, StatisticsState>(
      (ref) => StatisticsViewModel(),
    );

class StatisticsViewModel extends StateNotifier<StatisticsState> {
  final DbHelper _dbHelper = getIt<DbHelper>();
  final FinancialAggregator _aggregator = FinancialAggregator();

  StatisticsViewModel() : super(StatisticsState()) {
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final income = await _aggregator.sumByType('income');
      final expense = await _aggregator.sumByType('expense');
      final balance = income - expense;

      final expByCatResult = await _dbHelper.complexQuery(
        table: 'transactions t',
        columns: [
          "COALESCE(c.name, 'Uncategorized') as category",
          'SUM(t.amount) as total',
        ],
        joinClause: 'LEFT JOIN categories c ON t.category_id = c.id',
        where: 't.type = ?',
        whereArgs: ['expense'],
        groupBy: 'category',
      );
      final expByCat = expByCatResult.fold(
        (_) => <String, double>{},
        (rows) => {
          for (var r in rows)
            r['category'] as String: (r['total'] as num).toDouble(),
        },
      );

      final incByCatResult = await _dbHelper.complexQuery(
        table: 'transactions t',
        columns: [
          "COALESCE(c.name, 'Uncategorized') as category",
          'SUM(t.amount) as total',
        ],
        joinClause: 'LEFT JOIN categories c ON t.category_id = c.id',
        where: 't.type = ?',
        whereArgs: ['income'],
        groupBy: 'category',
      );
      final incByCat = incByCatResult.fold(
        (_) => <String, double>{},
        (rows) => {
          for (var r in rows)
            r['category'] as String: (r['total'] as num).toDouble(),
        },
      );

      final accs = await _aggregator.balancesPerAccount();

      final goalsResult = await _dbHelper.queryAllRows('goals');
      final goals = goalsResult.fold(
        (_) => <String, double>{},
        (rows) => {
          for (var r in rows)
            r['name'] as String: _goalProgressPercent(
              (r['current_amount'] as num).toDouble(),
              (r['target'] as num).toDouble(),
            ),
        },
      );

      final budgetResult = await _dbHelper.queryAllRows('budgets');
      final budgets = <String, double>{};
      await budgetResult.fold((_) async {}, (rows) async {
        for (final r in rows) {
          final id = r['id'];
          final amount = (r['amount'] as num).toDouble();
          final accountId = r['account_id'] as int;
          final start = r['start_date']?.toString() ?? '';
          final end = r['end_date']?.toString() ?? '';
          final spent = await _aggregator.expensesInRange(
            accountId: accountId,
            startDate: start,
            endDate: end,
          );
          budgets['Budget #$id'] =
              amount <= 0 ? 0 : ((spent / amount) * 100).clamp(0, 999);
        }
      });

      state = state.copyWith(
        totalIncome: income,
        totalExpense: expense,
        currentBalance: balance,
        expenseByCategory: expByCat,
        incomeByCategory: incByCat,
        accountsBalance: accs,
        goalsProgress: goals,
        budgetsProgress: budgets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  static double _goalProgressPercent(double current, double target) {
    if (target <= 0) return 0;
    return ((current / target) * 100).clamp(0, 100);
  }
}
