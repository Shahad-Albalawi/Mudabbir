import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/service/chatbot/chatbot_local_fallback.dart';

void main() {
  group('ChatbotLocalFallback', () {
    final insights = {
      'monthly_income': 5000.0,
      'monthly_expense': 3200.0,
      'monthly_balance': 1800.0,
      'score': 72,
      'alerts': <String>[],
    };

    final contextData = {
      'goals': [
        {
          'name': 'سيارة',
          'target': 20000,
          'current_amount': 5000,
        },
      ],
      'budgets': [
        {
          'amount': 4000,
          'start_date': '2020-01-01',
          'end_date': '2030-12-31',
        },
      ],
      'transactions': <Map<String, dynamic>>[],
      'categories': <Map<String, dynamic>>[],
    };

    test('builds goals-focused reply', () {
      final reply = ChatbotLocalFallback.buildReply(
        userMessage: 'كيف أهدافي؟',
        contextData: contextData,
        insights: insights,
      );

      expect(reply.contains('سيارة'), isTrue);
      expect(reply.contains('5000'), isTrue);
    });

    test('builds default snapshot for generic question', () {
      final reply = ChatbotLocalFallback.buildReply(
        userMessage: 'ساعدني',
        contextData: contextData,
        insights: insights,
      );

      expect(reply.contains('5000'), isTrue);
      expect(reply.contains('3200'), isTrue);
      expect(reply.contains('72'), isTrue);
    });
  });
}
