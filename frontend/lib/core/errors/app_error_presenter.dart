import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_snackbar.dart';

/// Unified user-facing error/success feedback for the whole app.
///
/// Always routes through [AppSnackbar] so title/body/placement stay consistent.
class AppErrorPresenter {
  AppErrorPresenter._();

  static void showFailure(
    Failure failure, {
    String? title,
  }) {
    AppSnackbar.error(
      failure.userFacingMessage,
      title: title ?? AppStrings.snackErrorTitle,
    );
  }

  static void showErrorMessage(
    String message, {
    String? title,
  }) {
    AppSnackbar.error(
      message,
      title: title ?? AppStrings.snackErrorTitle,
    );
  }

  static void showSuccess(
    String message, {
    String? title,
  }) {
    AppSnackbar.success(
      message,
      title: title ?? AppStrings.snackSuccessTitle,
    );
  }

  static void showWarning(
    String message, {
    String? title,
  }) {
    AppSnackbar.warning(
      message,
      title: title ?? AppStrings.snackWarningTitle,
    );
  }

  static void showInfo(
    String message, {
    String? title,
  }) {
    AppSnackbar.info(
      message,
      title: title ?? AppStrings.snackInfoTitle,
    );
  }
}
