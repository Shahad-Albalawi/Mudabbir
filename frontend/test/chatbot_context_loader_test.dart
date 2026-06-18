import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mudabbir/data/local/challenge_hive_cache.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/service/chatbot/chatbot_context_loader.dart';

void main() {
  setUpAll(() async {
    Hive.init('./.dart_tool/test_hive');
  });

  test('ChatbotContextLoader uses Hive when database context is empty', () async {
    final expenseCache = ExpenseHiveCache();
    final goalCache = GoalHiveCache();
    final challengeCache = ChallengeHiveCache();

    await expenseCache.init();
    await goalCache.init();
    await challengeCache.init();
    await expenseCache.clearAll();
    await goalCache.clearAll();
    await challengeCache.clearAll();

    await expenseCache.saveExpensesList([
      {
        'id': 1,
        'amount': 120.0,
        'date': '2026-06-01',
        'type': 'expense',
        'account_id': 1,
        'category_id': 2,
        'account_name': 'Cash',
        'category_name': 'Food',
      },
    ]);
    await goalCache.saveGoalsList([
      {
        'id': 9,
        'name': 'Emergency',
        'target': 1000,
        'current_amount': 200,
        'type': 'Saving',
        'start_date': '2026-01-01',
        'end_date': '2026-12-31',
        'is_completed': false,
      },
    ]);

    final loader = ChatbotContextLoader(
      databaseContextLoader: () async => {},
      expenseCache: expenseCache,
      goalCache: goalCache,
      challengeCache: challengeCache,
    );

    final context = await loader.load();

    expect((context['transactions'] as List).length, 1);
    expect((context['goals'] as List).first['name'], 'Emergency');
    expect((context['categories'] as List).isNotEmpty, isTrue);
  });
}
