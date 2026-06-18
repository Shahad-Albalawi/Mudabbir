import 'package:mudabbir/data/local/challenge_hive_cache.dart';
import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/domain/services/financial_aggregator.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/utils/dev_log.dart';

/// Loads chatbot financial context from SQLite, with Hive cache fallback.
class ChatbotContextLoader {
  ChatbotContextLoader({
    DbHelper? dbHelper,
    ExpenseHiveCache? expenseCache,
    GoalHiveCache? goalCache,
    ChallengeHiveCache? challengeCache,
    FinancialAggregator? aggregator,
    Future<Map<String, dynamic>> Function()? databaseContextLoader,
  })  : _dbHelper = dbHelper,
        _expenseCache = expenseCache,
        _goalCache = goalCache,
        _challengeCache = challengeCache,
        _aggregator = aggregator,
        _databaseContextLoader = databaseContextLoader;

  final DbHelper? _dbHelper;
  final ExpenseHiveCache? _expenseCache;
  final GoalHiveCache? _goalCache;
  final ChallengeHiveCache? _challengeCache;
  final FinancialAggregator? _aggregator;
  final Future<Map<String, dynamic>> Function()? _databaseContextLoader;

  Future<Map<String, dynamic>> load() async {
    try {
      final fromDb = _databaseContextLoader != null
          ? await _databaseContextLoader()
          : await _loadFromDatabase();
      if (_hasUsableData(fromDb)) {
        return fromDb;
      }
    } catch (e) {
      devLog('ChatbotContextLoader: SQLite unavailable ($e), using Hive fallback');
    }

    return _loadFromHive();
  }

  bool _hasUsableData(Map<String, dynamic> context) {
    for (final key in ['transactions', 'goals', 'budgets', 'accounts']) {
      final value = context[key];
      if (value is List && value.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  Future<Map<String, dynamic>> _loadFromDatabase() async {
    final dbHelper = _dbHelper ?? getIt<DbHelper>();
    final aggregator = _aggregator ?? FinancialAggregator(db: dbHelper);
    final context = <String, dynamic>{};

    final accountsResult = await dbHelper.queryAllRows('accounts');
    context['accounts'] = await accountsResult.fold(
      (_) async => <Map<String, dynamic>>[],
      (data) async {
        final enriched = <Map<String, dynamic>>[];
        for (final row in data) {
          final id = row['id'] as int;
          final balance = await aggregator.ledgerBalance(accountId: id);
          enriched.add({...row, 'balance': balance});
        }
        return enriched;
      },
    );

    final categoriesResult = await dbHelper.queryAllRows('categories');
    categoriesResult.fold(
      (_) => context['categories'] = <Map<String, dynamic>>[],
      (data) => context['categories'] = data,
    );

    final transactionsResult = await dbHelper.queryAllRows('transactions');
    transactionsResult.fold(
      (_) => context['transactions'] = <Map<String, dynamic>>[],
      (data) => context['transactions'] = data,
    );

    final budgetsResult = await dbHelper.queryAllRows('budgets');
    budgetsResult.fold(
      (_) => context['budgets'] = <Map<String, dynamic>>[],
      (data) => context['budgets'] = data,
    );

    final goalsResult = await dbHelper.queryAllRows('goals');
    goalsResult.fold(
      (_) => context['goals'] = <Map<String, dynamic>>[],
      (data) => context['goals'] = data,
    );

    final challengesResult = await dbHelper.queryAllRows('challenges');
    challengesResult.fold(
      (_) => context['challenges'] = <Map<String, dynamic>>[],
      (data) => context['challenges'] = data,
    );

    return context;
  }

  Map<String, dynamic> _loadFromHive() {
    final expenseCache = _expenseCache ?? getIt<ExpenseHiveCache>();
    final goalCache = _goalCache ?? getIt<GoalHiveCache>();
    final challengeCache = _challengeCache ?? getIt<ChallengeHiveCache>();

    final transactions =
        List<Map<String, dynamic>>.from(expenseCache.getExpensesList() ?? []);
    final goals = (goalCache.getGoalsList() ?? [])
        .map(_goalRowFromCache)
        .toList();
    final challenges =
        List<Map<String, dynamic>>.from(challengeCache.getChallengesList() ?? []);

    final accounts = <Map<String, dynamic>>[];
    final categories = <String, Map<String, dynamic>>{};
    for (final tx in transactions) {
      final accountId = (tx['account_id'] as num?)?.toInt() ?? 0;
      final categoryId = (tx['category_id'] as num?)?.toInt() ?? 0;
      final accountName = tx['account_name']?.toString() ?? '';
      final categoryName = tx['category_name']?.toString() ?? '';

      if (accountId > 0 && !accounts.any((a) => a['id'] == accountId)) {
        accounts.add({
          'id': accountId,
          'name': accountName,
          'balance': 0,
        });
      }
      if (categoryId > 0) {
        categories[categoryId.toString()] = {
          'id': categoryId,
          'name': categoryName,
        };
      }
    }

    return {
      'accounts': accounts,
      'categories': categories.values.toList(),
      'transactions': transactions,
      'budgets': <Map<String, dynamic>>[],
      'goals': goals,
      'challenges': challenges,
    };
  }

  Map<String, dynamic> _goalRowFromCache(Map<String, dynamic> map) {
    final completed = map['is_completed'] == true || map['is_completed'] == 1;
    return {
      'id': map['id'],
      'name': map['name'],
      'target': map['target'],
      'current_amount': map['current_amount'],
      'type': map['type'],
      'start_date': map['start_date'],
      'end_date': map['end_date'],
      'image_path': map['image_path'],
      'is_completed': completed ? 1 : 0,
      'completed_at': map['completed_at'],
    };
  }
}
