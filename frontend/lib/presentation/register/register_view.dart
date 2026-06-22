import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/presentation/auth/auth_flow_layout.dart';
import 'package:mudabbir/presentation/auth/auth_text_field.dart';
import 'package:mudabbir/presentation/register/register_viewmodel.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_animated_list_item.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';
import 'package:mudabbir/utils/dev_log.dart';

import '../auth/auth_form_validators.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _scrollController = ScrollController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _scrollController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }
    ref.read(registerProvider.notifier).register(
          _firstNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _confirmPasswordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final registerState = ref.watch(registerProvider);

    ref.listen<RegisterState>(registerProvider, (
      previousState,
      newState,
    ) async {
      if (newState.failure != null) {
        getIt<NavigationService>().showErrorSnackbar(
          title: AppStrings.snackErrorTitle,
          body: newState.failure!.userFacingMessage,
        );
      } else if (newState.user != null && !newState.isLoading) {
        try {
          getIt<NavigationService>().showSuccessSnackbar(
            title: AppStrings.snackSuccessTitle,
            body: AppStrings.registerSuccessBody,
          );

          final userModel = newState.user!;
          final userMap = {
            'name': userModel.name,
            'email': userModel.email,
            'id': userModel.id,
          };
          final token = await getIt<AuthTokenSecureStore>().readToken();

          if (token != null && token.isNotEmpty) {
            await getIt<AuthNotifier>().didLogin(userMap, token);
            await Future.delayed(const Duration(milliseconds: 100));
            devLog('تم التسجيل بنجاح');
          } else {
            getIt<NavigationService>().showErrorSnackbar(
              title: AppStrings.snackErrorTitle,
              body: AppStrings.loginSessionError,
            );
          }
        } catch (e) {
          devLog('خطأ أثناء عملية التسجيل: $e');
          getIt<NavigationService>().showErrorSnackbar(
            title: AppStrings.snackErrorTitle,
            body: AppStrings.registerCatchError,
          );
        }
      }
    });

    return AppGroupedScaffold(
      useAppBar: false,
      body: AuthFlowLayout(
        title: AppStrings.createAccount,
        subtitle: AppStrings.registerSubtitle,
        scrollController: _scrollController,
        child: AutofillGroup(
          child: Column(
            children: [
              AppFadeIn(
                delay: const Duration(milliseconds: 80),
                child: AppCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthTextField(
                          label: AppStrings.firstNameLabel,
                          hint: AppStrings.firstNameHint,
                          controller: _firstNameController,
                          icon: Icons.person_outline,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          validator: AuthFormValidators.firstName,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          label: AppStrings.emailLabel,
                          hint: AppStrings.emailHint,
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: AuthFormValidators.email,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          label: AppStrings.passwordLabel,
                          hint: AppStrings.passwordHint,
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          obscurable: true,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          validator: AuthFormValidators.password,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            AppStrings.validationPasswordMinLength,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: scheme.textMuted),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          label: AppStrings.confirmPasswordLabel,
                          hint: AppStrings.confirmPasswordHint,
                          controller: _confirmPasswordController,
                          icon: Icons.lock_outline,
                          obscurable: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (value) => AuthFormValidators.confirmPassword(
                            value,
                            _passwordController.text,
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppLoadingButton(
                          isLoading: registerState.isLoading,
                          label: AppStrings.createAccountButton,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
                const SizedBox(height: 16),
              AppFadeIn(
                    delay: const Duration(milliseconds: 140),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.textMuted,
                              ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            AppStrings.signInLink,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
