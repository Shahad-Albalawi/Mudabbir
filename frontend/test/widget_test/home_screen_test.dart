import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/core/widgets/riyal_text.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/presentation/home/home_screen.dart';
import 'package:mudabbir/presentation/home/home_screen_provider.dart';
import 'package:mudabbir/presentation/notifications/notifications_provider.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

import '../helpers/home_test_locator.dart';
import '../helpers/widget_test_helpers.dart';

HomeScreenState _seedHomeState() {
  return HomeScreenState(
    isLoading: false,
    userName: 'شهد',
    balance: 5000,
    monthlyIncome: 8000,
    monthlyExpense: 3000,
    recentTransactions: const [
      ExpenseTransaction(
        id: 1,
        amount: 120,
        date: '2026-06-20',
        type: 'expense',
        notes: 'قهوة الصباح',
        accountId: 1,
        categoryId: 1,
        accountName: 'محفظة',
        categoryName: 'food',
      ),
      ExpenseTransaction(
        id: 2,
        amount: 2500,
        date: '2026-06-19',
        type: 'income',
        notes: 'راتب',
        accountId: 1,
        categoryId: 2,
        accountName: 'محفظة',
        categoryName: 'salary',
      ),
    ],
    monthlyBudget: const HomeMonthlyBudget(limit: 4000, spent: 3000),
  );
}

void main() {
  group('HomeScreen', () {
    late HomeScreenState seedState;

    setUpAll(() async {
      await bootstrapHomeWidgetTests();
    });

    setUp(() {
      seedState = _seedHomeState();
    });

    Future<void> pumpHome(WidgetTester tester, Widget child, {GoRouter? router}) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapForWidgetTest(
          child: child,
          router: router,
          overrides: [
            homeScreenProvider.overrideWith(
              (ref) => HomeScreenNotifier.preview(ref, seedState),
            ),
            notificationsProvider.overrideWith(
              (ref) => NotificationsNotifier(loadOnInit: false),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      clearBenignLayoutExceptions(tester);
    }

    testWidgets('shows balance card with total balance label', (tester) async {
      await pumpHome(tester, const HomeScreen());

      expect(find.text('إجمالي الرصيد'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RiyalText && widget.amount == 5000,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows recent transactions list', (tester) async {
      await pumpHome(tester, const HomeScreen());

      expect(find.text('آخر المعاملات'), findsOneWidget);
      expect(find.text('قهوة الصباح'), findsOneWidget);
      expect(find.text('راتب'), findsOneWidget);
    });

    testWidgets('navigates to budget screen when tapping manage on budget',
        (tester) async {
      const budgetMarker = Key('test-budget-route');

      final router = GoRouter(
        initialLocation: AppRoutes.home,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.budget,
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('BUDGET', key: budgetMarker)),
            ),
          ),
        ],
      );

      await pumpHome(
        tester,
        const SizedBox.shrink(),
        router: router,
      );

      expect(find.text('الميزانية'), findsOneWidget);

      await tester.tap(find.text('إدارة'));
      await tester.pumpAndSettle();

      expect(find.byKey(budgetMarker), findsOneWidget);
    });
  });
}
