import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/service/getit_init.dart';

class StatisticsState {
  final double totalIncome;
  final double totalExpense;
  final double currentBalance;
  final Map<String, double> expenseByCategory;
  final Map<String, double> incomeByCategory;
  final Map<String, double> accountsBalance;
  final Map<String, double> goalsProgress; // goalName → %
  final Map<String, double> budgetsProgress; // budgetName → %

  final bool isLoading;

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
    );
  }
}

final statisticsProvider =
    StateNotifierProvider<StatisticsViewModel, StatisticsState>(
      (ref) => StatisticsViewModel(),
    );

class StatisticsViewModel extends StateNotifier<StatisticsState> {
  final DbHelper _dbHelper = getIt<DbHelper>();

  StatisticsViewModel() : super(StatisticsState()) {
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true);

    try {
      // ✅ Total Income
      final incomeResult = await _dbHelper.complexQuery(
        table: "transactions",
        columns: ["SUM(amount) as total"],
        where: "type = ?",
        whereArgs: ["income"],
      );
      final income = incomeResult.fold(
        (_) => 0.0,
        (rows) => (rows.first["total"] as num?)?.toDouble() ?? 0.0,
      );

      // ✅ Total Expense
      final expenseResult = await _dbHelper.complexQuery(
        table: "transactions",
        columns: ["SUM(amount) as total"],
        where: "type = ?",
        whereArgs: ["expense"],
      );
      final expense = expenseResult.fold(
        (_) => 0.0,
        (rows) => (rows.first["total"] as num?)?.toDouble() ?? 0.0,
      );

      final balance = income - expense;

      // ✅ Expense by category
      final expByCatResult = await _dbHelper.complexQuery(
        table: "transactions t",
        columns: ["c.name as category, SUM(t.amount) as total"],
        joinClause: "JOIN categories c ON t.category_id = c.id",
        where: "t.type = ?",
        whereArgs: ["expense"],
        groupBy: "c.name",
      );
      final expByCat = expByCatResult.fold(
        (_) => <String, double>{},
        (rows) => {
          for (var r in rows)
            r["category"] as String: (r["total"] as num).toDouble(),
        },
      );

      // ✅ Income by category
      final incByCatResult = await _dbHelper.complexQuery(
        table: "transactions t",
        columns: ["c.name as category, SUM(t.amount) as total"],
        joinClause: "JOIN categories c ON t.category_id = c.id",
        where: "t.type = ?",
        whereArgs: ["income"],
        groupBy: "c.name",
      );
      final incByCat = incByCatResult.fold(
        (_) => <String, double>{},
        (rows) => {
          for (var r in rows)
            r["category"] as String: (r["total"] as num).toDouble(),
        },
      );

      // ✅ Accounts
      final accResult = await _dbHelper.queryAllRows("accounts");
      final accs = accResult.fold(
        (_) => <String, double>{},
        (rows) => {
          for (var r in rows)
            r["name"] as String: (r["balance"] as num).toDouble(),
        },
      );

      // ✅ Goals
      final goalsResult = await _dbHelper.queryAllRows("goals");
      final goals = goalsResult.fold(
        (_) => <String, double>{},
        (rows) => {
          for (var r in rows)
            r["name"] as String:
                ((r["current_amount"] as num) / (r["target"] as num)) * 100,
        },
      );

      // ✅ Budgets
      final budgetResult = await _dbHelper.queryAllRows("budgets");
      final budgets = budgetResult.fold(
        (_) => <String, double>{},
        (rows) => {
          for (var r in rows)
            "Budget #${r["id"]}":
                ((0.0) / (r["amount"] as num)) * 100, // placeholder
        },
      );

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
      state = state.copyWith(isLoading: false);
    }
  }
}
