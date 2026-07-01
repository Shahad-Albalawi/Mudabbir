import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

abstract final class AuthUi {
  AuthUi._();

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, textAlign: TextAlign.right),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          margin: const EdgeInsets.all(Spacing.lg),
        ),
      );
  }

  static String messageForFailure(Failure failure) {
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return AppStrings.authNetworkError;
    }
    if (failure is ServerFailure && failure.code == 401) {
      return AppStrings.authInvalidCredentials;
    }
    if (failure is ValidationFieldsFailure) {
      return failure.fieldErrors.values.first;
    }
    return failure.userFacingMessage;
  }

  static bool shouldShowSnackBar(Failure failure) {
    if (failure is ValidationFieldsFailure) {
      return failure.fieldErrors.isEmpty;
    }
    if (failure is ServerFailure && failure.code == 422) {
      return false;
    }
    return true;
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(child: Divider(color: colors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Text(
            AppStrings.authOrDivider,
            style: textTheme.labelMedium?.copyWith(color: colors.textSecondary),
          ),
        ),
        Expanded(child: Divider(color: colors.divider)),
      ],
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.leading,
    required this.action,
    required this.onTap,
  });

  final String leading;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: RichText(
        text: TextSpan(
          style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          children: [
            TextSpan(text: leading),
            TextSpan(
              text: action,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  static const double height = 52;

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy1,
          foregroundColor: AppColors.textInverse,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textInverse,
                  ),
                ),
              )
            : Text(label),
      ),
    );
  }
}
