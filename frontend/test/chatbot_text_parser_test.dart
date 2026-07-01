import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/service/chatbot/chatbot_text_parser.dart';

void main() {
  group('ChatbotTextParser', () {
    test('extractFirstNumber parses decimal from mixed text', () {
      expect(ChatbotTextParser.extractFirstNumber('أوفر 300 كل شهر'), 300);
      expect(ChatbotTextParser.extractFirstNumber('save 1500.5 monthly'), 1500.5);
      expect(ChatbotTextParser.extractFirstNumber('no digits'), isNull);
    });

    test('extractMonths reads Arabic and English duration', () {
      expect(ChatbotTextParser.extractMonths('خلال 12 شهر'), 12);
      expect(ChatbotTextParser.extractMonths('in 6 months'), 6);
      expect(ChatbotTextParser.extractMonths('بدون مدة'), isNull);
    });

    test('extractGoalName strips amount and duration', () {
      expect(
        ChatbotTextParser.extractGoalName('أنشئ هدف سيارة 25000 خلال 12 شهر'),
        'سيارة',
      );
      expect(
        ChatbotTextParser.extractGoalName('create goal vacation 5000 in 3 months'),
        'vacation',
      );
    });

    test('intent detectors match keywords', () {
      expect(ChatbotTextParser.isInsightQuestion('ما تقييمي المالي؟'), isTrue);
      expect(ChatbotTextParser.isWhatIfQuestion('لو أوفر 200'), isTrue);
      expect(ChatbotTextParser.isSubscriptionQuestion('اشتراكاتي'), isTrue);
      expect(ChatbotTextParser.isGoalOptimizerQuestion('حسن اهدافي'), isTrue);
      expect(ChatbotTextParser.isReportQuestion('صدّر تقرير pdf'), isTrue);
      expect(ChatbotTextParser.isReportQuestion('مرحبا'), isFalse);
    });
  });
}
