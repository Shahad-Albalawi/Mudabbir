import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/features/auth/auth_validators.dart';
import 'package:mudabbir/features/auth/password_reset_notifier.dart';
import 'package:mudabbir/features/auth/widgets/auth_logo_header.dart';
import 'package:mudabbir/features/auth/widgets/auth_text_field.dart';
import 'package:mudabbir/features/auth/widgets/auth_ui.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(passwordResetProvider.notifier)
        .requestCode(_emailController.text);
  }

  void _handleState(PasswordResetState next) {
    if (next.outcome == PasswordResetOutcome.codeSent) {
      ref.read(passwordResetProvider.notifier).reset();
      if (!mounted) return;
      AuthUi.showSuccessSnackBar(context, AppStrings.authForgotPasswordSent);
      context.go(
        AppRoutes.resetPassword,
        extra: _emailController.text.trim(),
      );
      return;
    }

    if (next.failure == null || next.isLoading) return;

    if (next.failure is ValidationFieldsFailure ||
        (next.failure is ServerFailure &&
            (next.failure as ServerFailure).code == 422)) {
      _formKey.currentState?.validate();
      return;
    }

    if (AuthUi.shouldShowSnackBar(next.failure!)) {
      AuthUi.showErrorSnackBar(
        context,
        AuthUi.messageForFailure(next.failure!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final resetState = ref.watch(passwordResetProvider);
    final fieldErrors = resetState.fieldErrors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<PasswordResetState>(passwordResetProvider, (_, next) {
      _handleState(next);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            elevation: 0,
            leading: IconButton(
              onPressed: () => context.go(AppRoutes.login),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colors.textPrimary,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AuthLogoHeader(),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    AppStrings.authForgotPasswordTitle,
                    style: textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.authForgotPasswordBody,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          controller: _emailController,
                          label: AppStrings.emailLabel,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: (v) => mergeFieldError(
                            AuthValidators.validateEmail(v),
                            fieldErrors['email'],
                          ),
                        ),
                        const SizedBox(height: Spacing.xxl),
                        AuthSubmitButton(
                          label: AppStrings.authForgotPasswordSubmit,
                          isLoading: resetState.isLoading,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(AppStrings.authBackToLogin),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
