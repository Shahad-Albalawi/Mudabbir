import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/domain/models/user/user_model.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/auth/login_screen.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';

import '../test/helpers/test_mocks.dart';
import 'test_helpers/auth_test_helpers.dart';

Future<void> _pumpAuthApp(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(390, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeUserRepository fakeUserRepository;

  setUpAll(() async {
    await bootstrapAuthIntegrationTests();
  });

  setUp(() async {
    fakeUserRepository = FakeUserRepository();
    await resetAuthTestLocator();
    registerMockUserRepository(fakeUserRepository);
  });

  group('Auth flow integration', () {
    testWidgets('complete registration flow navigates to home', (tester) async {
      const homeMarker = Key('auth-test-home-register');

      fakeUserRepository.registerHandler = (
        name,
        email,
        password,
        passwordConfirmation,
      ) async {
        expect(name, 'مستخدم جديد');
        expect(email, 'new@example.com');
        expect(password, 'password123');
        expect(passwordConfirmation, 'password123');
        await getIt<AuthTokenSecureStore>().writeToken('integration-token');
        return Right(
          UserModel(
            id: 10,
            name: 'مستخدم جديد',
            email: 'new@example.com',
          ),
        );
      };

      final auth = getIt<AuthNotifier>();
      await waitForAuthNotifierInit(auth);

      final router = GoRouter(
        initialLocation: AppRoutes.register,
        routes: [
          GoRoute(
            path: AppRoutes.register,
            builder: (_, __) => const RegisterScreen(),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('HOME', key: homeMarker)),
            ),
          ),
        ],
      );

      await _pumpAuthApp(
        tester,
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'مستخدم جديد');
      await tester.enterText(fields.at(1), 'new@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(AppStrings.authRegisterSubmit));
      await tester.tap(find.text(AppStrings.authRegisterSubmit));
      await tester.pumpAndSettle();

      expect(find.byKey(homeMarker), findsOneWidget);
      expect(auth.isLoggedIn, isTrue);
    });

    testWidgets('login flow stores session and navigates to home', (tester) async {
      const homeMarker = Key('auth-test-home');

      fakeUserRepository.loginHandler = (email, password) async {
        expect(email, 'user@example.com');
        expect(password, 'password123');
        await getIt<AuthTokenSecureStore>().writeToken('integration-token');
        return Right(
          UserModel(
            id: 1,
            name: 'شهد',
            email: email,
          ),
        );
      };

      final auth = getIt<AuthNotifier>();
      await waitForAuthNotifierInit(auth);

      final router = GoRouter(
        initialLocation: AppRoutes.login,
        routes: [
          GoRoute(
            path: AppRoutes.login,
            builder: (_, __) => const LoginScreen(),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (_, __) => const Scaffold(
              body: Center(child: Text('HOME', key: homeMarker)),
            ),
          ),
        ],
      );

      await _pumpAuthApp(
        tester,
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(1), 'password123');

      await tester.ensureVisible(find.text(AppStrings.signIn));
      await tester.tap(find.text(AppStrings.signIn));
      await tester.pumpAndSettle();

      expect(find.byKey(homeMarker), findsOneWidget);
      expect(auth.isLoggedIn, isTrue);
      expect(
        getIt<HiveService>().getValue(HiveConstants.savedUserInfo),
        isNotNull,
      );
    });

    testWidgets('logout flow clears session and auth state', (tester) async {
      final auth = getIt<AuthNotifier>();
      await waitForAuthNotifierInit(auth);

      await auth.didLogin(
        {'name': 'شهد', 'email': 'user@example.com', 'id': 1},
        'session-token',
      );
      expect(auth.isLoggedIn, isTrue);
      expect(
        getIt<HiveService>().getValue(HiveConstants.savedUserInfo),
        isNotNull,
      );

      await auth.didLogout();

      expect(auth.isLoggedIn, isFalse);
      expect(getIt<HiveService>().getValue(HiveConstants.savedUserInfo), isNull);
      expect(await getIt<AuthTokenSecureStore>().readToken(), isNull);
    });
  });
}
