import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/presentation/expenses/expenses_viewmodel.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

void main() {
  group('ExpensesNotifier', () {
    test('currentMonthKey formats YYYY-MM', () {
      expect(ExpensesNotifier.currentMonthKey(), matches(RegExp(r'^\d{4}-\d{2}$')));
    });
  });

  group('ExpensesState', () {
    test('copyWith clears messages when requested', () {
      final state = ExpensesState(errorMessage: 'err', successMessage: 'ok');
      final cleared = state.copyWith(clearError: true, clearSuccess: true);
      expect(cleared.errorMessage, isNull);
      expect(cleared.successMessage, isNull);
    });
  });

  group('AppRoutes', () {
    test('challengeDetail embeds id', () {
      expect(AppRoutes.challengeDetail(42), '/challenges/42');
    });

    test('feature paths are stable', () {
      expect(AppRoutes.expenses, '/expenses');
      expect(AppRoutes.chatbot, '/chatbot');
      expect(AppRoutes.challengesCreate, '/challenges/create');
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.privacyPolicy, '/privacy');
    });
  });

  group('AppStrings auth validation', () {
    test('Arabic validation messages are non-empty', () {
      expect(AppStrings.validationEmailRequired, isNotEmpty);
      expect(AppStrings.validationPasswordMinLength, isNotEmpty);
      expect(AppStrings.validationPasswordMismatch, isNotEmpty);
    });
  });
}
