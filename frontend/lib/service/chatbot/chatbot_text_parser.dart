import 'package:mudabbir/presentation/chatbot/chatbot_copy_helpers.dart';

/// Pure text parsing and intent detection for chatbot commands.
abstract final class ChatbotTextParser {
  static int? extractMonths(String text) {
    final monthRegex = RegExp(
      r'(\d+)\s*(شهر|شهور|months?|month)',
      caseSensitive: false,
    );
    final match = monthRegex.firstMatch(text);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  static String extractGoalName(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'create goal', caseSensitive: false), '')
        .replaceAll('أنشئ هدف', '')
        .replaceAll('انشئ هدف', '')
        .trim();
    var name = cleaned.replaceFirst(RegExp(r'\d+(\.\d+)?'), '').trim();
    name = name.replaceAll(
      RegExp(
        r'(خلال|in)\s*\d+\s*(شهر|شهور|months?|month)',
        caseSensitive: false,
      ),
      '',
    );
    name = name.trim();
    if (name.isEmpty) return ChatbotUi.defaultNewGoalName;
    return name;
  }

  static double? extractFirstNumber(String text) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }

  static bool isInsightQuestion(String message) {
    final q = message.toLowerCase();
    return q.contains('الصحة المالية') ||
        q.contains('score') ||
        q.contains('سكور') ||
        q.contains('تقييمي') ||
        q.contains('الانفاق مرتفع') ||
        q.contains('غير طبيعي') ||
        q.contains('تنبيه');
  }

  static bool isWhatIfQuestion(String message) {
    final q = message.toLowerCase();
    return q.contains('ماذا لو') ||
        q.contains('لو ') ||
        q.contains('what if') ||
        q.contains('اوفر') ||
        q.contains('أوفر') ||
        q.contains('ادخر') ||
        q.contains('أدخر');
  }

  static bool isSubscriptionQuestion(String message) {
    final q = message.toLowerCase();
    return q.contains('اشتراك') ||
        q.contains('الاشتراكات') ||
        q.contains('متكرر') ||
        q.contains('شهري') ||
        q.contains('subscription');
  }

  static bool isGoalOptimizerQuestion(String message) {
    final q = message.toLowerCase();
    return q.contains('goal optimizer') ||
        q.contains('optimize') ||
        q.contains('حسن اهدافي') ||
        q.contains('وزع الادخار') ||
        q.contains('خطة الأهداف');
  }

  static bool isReportQuestion(String message) {
    final q = message.toLowerCase();
    return q.contains('pdf') ||
        q.contains('report') ||
        q.contains('تقرير') ||
        q.contains('تصدير');
  }
}
