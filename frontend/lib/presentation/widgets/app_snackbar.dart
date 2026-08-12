import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/core/providers/provider_reader.dart';
import 'package:mudabbir/service/navigation_service.dart';

/// Unified iOS-style in-app feedback (floating card via [NavigationService]).
class AppSnackbar {
  AppSnackbar._();

  static NavigationService get _nav => readApp(navigationServiceProvider);

  static void success(String body, {String? title}) {
    _nav.showSuccessSnackbar(
      title: title ?? AppStrings.snackSuccessTitle,
      body: body,
    );
  }

  static void error(String body, {String? title}) {
    _nav.showErrorSnackbar(
      title: title ?? AppStrings.snackErrorTitle,
      body: body,
    );
  }

  static void warning(String body, {String? title}) {
    _nav.showWarningSnackbar(
      title: title ?? AppStrings.snackWarningTitle,
      body: body,
    );
  }

  static void info(String body, {String? title}) {
    _nav.showInfoSnackbar(
      title: title ?? AppStrings.snackInfoTitle,
      body: body,
    );
  }
}
