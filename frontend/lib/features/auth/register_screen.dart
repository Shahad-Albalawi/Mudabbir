import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/features/auth/auth_screen_notifier.dart';
import 'package:mudabbir/features/auth/auth_validators.dart';
import 'package:mudabbir/features/auth/widgets/auth_logo_header.dart';
import 'package:mudabbir/features/auth/widgets/auth_terms_checkbox.dart';
import 'package:mudabbir/features/auth/widgets/auth_text_field.dart';
import 'package:mudabbir/features/auth/widgets/auth_ui.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

/// iOS-style registration for مدبّر.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmController.clear();
    _isPasswordVisible = false;
    _isConfirmVisible = false;
    _acceptedTerms = false;
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    if (!_acceptedTerms) {
      AuthUi.showErrorSnackBar(
        context,
        AppStrings.authTermsAcceptRequired,
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(authScreenProvider.notifier).register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
          _confirmController.text,
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
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: () => context.go(AppRoutes.login),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AuthLogoHeader(),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      AppStrings.authRegisterTitle,
                      style: textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.authRegisterTagline,
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
                            controller: _nameController,
                            label: AppStrings.authFullNameLabel,
                            icon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            validator: (v) => mergeFieldError(
                              AuthValidators.validateName(v),
                              fieldErrors['name'],
                            ),
                          ),
                          const SizedBox(height: Spacing.lg),
                          AuthTextField(
                            controller: _emailController,
                            label: AppStrings.emailLabel,
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
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
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
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
                          const SizedBox(height: Spacing.lg),
                          AuthTextField(
                            controller: _confirmController,
                            label: AppStrings.confirmPasswordLabel,
                            icon: Icons.lock_outline_rounded,
                            obscureText: !_isConfirmVisible,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
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
                          const SizedBox(height: Spacing.md),
                          AuthTermsCheckbox(
                            value: _acceptedTerms,
                            onChanged: (v) => setState(() => _acceptedTerms = v),
                            label: AppStrings.authTermsCheckboxLabel,
                          ),
                          const SizedBox(height: Spacing.lg),
                          AuthSubmitButton(
                            label: AppStrings.authRegisterSubmit,
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
                      leading: AppStrings.alreadyHaveAccount,
                      action: AppStrings.signInLink,
                      onTap: () => context.go(AppRoutes.login),
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
