import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/l10n/app_localizations.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Wraps a widget with Riverpod, Arabic locale, and optional router.
Widget wrapForWidgetTest({
  required Widget child,
  List<Override> overrides = const [],
  GoRouter? router,
  String routePath = '/',
}) {
  AppStrings.bind(lookupAppLocalizations(const Locale('ar')));

  final localizations = const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  final resolvedRouter = router ??
      GoRouter(
        routes: [
          GoRoute(
            path: routePath,
            builder: (_, __) => child,
          ),
        ],
      );

  if (router != null) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: localizations,
        routerConfig: router,
      ),
    );
  }

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: localizations,
      routerConfig: resolvedRouter,
    ),
  );
}

/// Clears non-fatal layout overflow exceptions from the test queue.
void clearBenignLayoutExceptions(WidgetTester tester) {
  Object? exception;
  while ((exception = tester.takeException()) != null) {
    if (!exception.toString().contains('overflowed')) {
      throw TestFailure(exception.toString());
    }
  }
}
