import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/service/chatbot/chatbot_insights_engine.dart';

void main() {
  group('ChatbotInsightsEngine', () {
    test('handleSimpleQuestions greets in Arabic', () {
      final reply = ChatbotInsightsEngine.handleSimpleQuestions('مرحبا');
      expect(reply, isNotNull);
      expect(reply!.isNotEmpty, isTrue);
    });

    test('handleSimpleQuestions answers who are you in English', () {
      final reply = ChatbotInsightsEngine.handleSimpleQuestions('who are you?');
      expect(reply, isNotNull);
    });

    test('buildFinancialInsights computes monthly totals', () {
      final now = DateTime(2025, 6, 15);
      final insights = ChatbotInsightsEngine.buildFinancialInsights(
        {
          'transactions': [
            {'date': '2025-06-01', 'amount': 5000, 'type': 'income'},
            {'date': '2025-06-10', 'amount': 1200, 'type': 'expense'},
            {'date': '2025-05-20', 'amount': 800, 'type': 'expense'},
          ],
        },
        now: now,
      );

      expect(insights['monthly_income'], 5000);
      expect(insights['monthly_expense'], 1200);
      expect(insights['monthly_balance'], 3800);
      expect(insights['score'], isA<int>());
    });

    test('buildWhatIfReply projects nearest goal', () {
      final reply = ChatbotInsightsEngine.buildWhatIfReply(
        'لو أوفر 500',
        {
          'goals': [
            {
              'name': 'سيارة',
              'target': 10000,
              'current_amount': 2000,
            },
          ],
        },
        now: DateTime(2025, 1, 1),
      );

      expect(reply.contains('سيارة'), isTrue);
      expect(reply.contains('500'), isTrue);
    });

    test('buildSubscriptionInsights groups recurring expenses', () {
      final insights = ChatbotInsightsEngine.buildSubscriptionInsights({
        'transactions': [
          {'type': 'expense', 'amount': 50, 'notes': 'Netflix'},
          {'type': 'expense', 'amount': 51, 'notes': 'Netflix'},
          {'type': 'expense', 'amount': 49, 'notes': 'Netflix'},
        ],
      });

      final subs = insights['subscriptions'] as List;
      expect(subs, isNotEmpty);
      expect(subs.first['label'], 'netflix');
    });
  });
}
