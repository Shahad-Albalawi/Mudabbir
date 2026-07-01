import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/data/network/failure.dart';

/// Shared iOS-style auth UI helpers.
abstract final class AuthUi {
  AuthUi._();

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, textAlign: TextAlign.right),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
          ),
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textAlign: TextAlign.right,
          ),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.md),
          ),
          margin: const EdgeInsets.all(AppSpacing.lg),
        ),
      );
  }

  static String messageForFailure(Failure failure) {
    if (failure is NetworkFailure || failure is TimeoutFailure) {
      return 'تحقق من اتصالك بالإنترنت';
    }
    if (failure is ServerFailure && failure.code == 401) {
      return 'البريد أو كلمة المرور غير صحيحة';
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

class AuthLogoHeader extends StatelessWidget {
  const AuthLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primarySurface,
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: colors.primary,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'مدبّر',
          style: textTheme.displaySmall?.copyWith(color: colors.primary),
        ),
      ],
    );
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'أو',
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

String? mergeFieldError(String? localError, String? serverError) {
  if (serverError != null && serverError.isNotEmpty) return serverError;
  return localError;
}
