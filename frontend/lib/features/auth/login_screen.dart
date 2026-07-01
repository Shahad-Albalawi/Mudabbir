import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/app_flags.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/features/auth/auth_screen_notifier.dart';
import 'package:mudabbir/features/auth/auth_validators.dart';
import 'package:mudabbir/features/auth/widgets/auth_logo_header.dart';
import 'package:mudabbir/features/auth/widgets/auth_text_field.dart';
import 'package:mudabbir/features/auth/widgets/auth_ui.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/routing_service/app_navigation.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

/// iOS-style login for مدبّر.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _isPasswordVisible = false;
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authScreenProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );
  }

  void _openForgotPassword() {
    AuthUi.showErrorSnackBar(
      context,
      AppStrings.authForgotPasswordSoon,
    );
  }

  void _handleAuthState(AuthScreenState next) {
    if (next.outcome == AuthScreenOutcome.success) {
      ref.read(authScreenProvider.notifier).reset();
      _clearForm();
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authScreenProvider);
    final fieldErrors = authState.fieldErrors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<AuthScreenState>(authScreenProvider, (_, next) {
      _handleAuthState(next);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xxl),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (AppFlags.allowGuestHome)
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: IconButton(
                          onPressed: () => AppNavigation.goHome(context),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 48),
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AuthLogoHeader(),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      AppStrings.authLoginTitle,
                      style: textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.authLoginTagline,
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
                          const SizedBox(height: Spacing.lg),
                          AuthTextField(
                            controller: _passwordController,
                            label: AppStrings.passwordLabel,
                            icon: Icons.lock_outline_rounded,
                            obscureText: !_isPasswordVisible,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _submit(),
                            trailing: IconButton(
                              onPressed: () => setState(
                                () =>
                                    _isPasswordVisible = !_isPasswordVisible,
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
                          const SizedBox(height: Spacing.sm),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: _openForgotPassword,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                AppStrings.authForgotPassword,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: Spacing.xxl),
                          AuthSubmitButton(
                            label: AppStrings.signIn,
                            isLoading: authState.isLoading,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const AuthOrDivider(),
                    const SizedBox(height: Spacing.xxl),
                    AuthFooterLink(
                      leading: AppStrings.noAccount,
                      action: AppStrings.authSignUpNow,
                      onTap: () => context.go(AppRoutes.register),
                    ),
                    const SizedBox(height: Spacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
