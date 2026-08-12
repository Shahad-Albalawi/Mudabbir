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

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(passwordResetProvider.notifier).resetPassword(
          email: widget.email,
          code: _codeController.text,
          password: _passwordController.text,
          passwordConfirmation: _confirmController.text,
        );
  }

  void _handleState(PasswordResetState next) {
    if (next.outcome == PasswordResetOutcome.resetSuccess) {
      ref.read(passwordResetProvider.notifier).reset();
      if (!mounted) return;
      context.go(AppRoutes.home);
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

  String? _validateCode(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return AppStrings.authResetCodeRequired;
    if (!RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return AppStrings.authResetCodeInvalid;
    }
    return null;
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
              onPressed: () => context.go(AppRoutes.forgotPassword),
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
                    AppStrings.authResetPasswordTitle,
                    style: textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.authResetPasswordBody,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          controller: _codeController,
                          label: AppStrings.authResetCodeLabel,
                          icon: Icons.pin_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (v) => mergeFieldError(
                            _validateCode(v),
                            fieldErrors['code'],
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                        AuthTextField(
                          controller: _passwordController,
                          label: AppStrings.passwordLabel,
                          icon: Icons.lock_outline_rounded,
                          obscureText: !_isPasswordVisible,
                          trailing: IconButton(
                            onPressed: () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: colors.textTertiary,
                            ),
                          ),
                          validator: (v) => mergeFieldError(
                            AuthValidators.validatePassword(v),
                            fieldErrors['password'],
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                        AuthTextField(
                          controller: _confirmController,
                          label: AppStrings.confirmPasswordLabel,
                          icon: Icons.lock_outline_rounded,
                          obscureText: !_isConfirmVisible,
                          trailing: IconButton(
                            onPressed: () => setState(
                              () => _isConfirmVisible = !_isConfirmVisible,
                            ),
                            icon: Icon(
                              _isConfirmVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: colors.textTertiary,
                            ),
                          ),
                          validator: (v) => mergeFieldError(
                            AuthValidators.validateConfirmPassword(
                              v,
                              _passwordController.text,
                            ),
                            fieldErrors['password_confirmation'],
                          ),
                        ),
                        const SizedBox(height: Spacing.xxl),
                        AuthSubmitButton(
                          label: AppStrings.authResetPasswordTitle,
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
