import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

/// Shared back navigation — reliable with [GoRouter].
abstract final class AppNavigation {
  static void goHome(BuildContext context) {
    final router = GoRouter.of(context);
    final location = router.state.matchedLocation;
    if (location == AppRoutes.home) return;
    router.go(AppRoutes.home);
  }

  static void goBackOr(BuildContext context, String fallbackRoute) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }
    final location = router.state.matchedLocation;
    if (location == fallbackRoute) {
      goHome(context);
      return;
    }
    router.go(fallbackRoute);
  }

  static VoidCallback homeHandler(BuildContext context) => () => goHome(context);

  static VoidCallback backHandler(
    BuildContext context, {
    String fallbackRoute = AppRoutes.home,
  }) =>
      () => goBackOr(context, fallbackRoute);
}
