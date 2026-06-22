import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/presentation/auth/auth_flow_layout.dart';
import 'package:mudabbir/presentation/auth/auth_text_field.dart';
import 'package:mudabbir/presentation/login/login_viewmodel.dart';
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

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(loginProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loginState = ref.watch(loginProvider);

    ref.listen<LoginState>(loginProvider, (previousState, newState) async {
      if (newState.failure != null) {
        getIt<NavigationService>().showErrorSnackbar(
          title: AppStrings.snackErrorTitle,
          body: newState.failure!.userFacingMessage,
        );
      } else if (newState.user != null && !newState.isLoading) {
        try {
          getIt<NavigationService>().showSuccessSnackbar(
            title: AppStrings.snackSuccessTitle,
            body: AppStrings.loginSuccessBody,
          );

          final userModel = newState.user!;
          final userMap = {'name': userModel.name, 'email': userModel.email, 'id': userModel.id};
          final token = await getIt<AuthTokenSecureStore>().readToken();

          if (token != null && token.isNotEmpty) {
            await getIt<AuthNotifier>().didLogin(userMap, token);
            await Future.delayed(const Duration(milliseconds: 100));
            devLog('تم تسجيل الدخول بنجاح');
          } else {
            getIt<NavigationService>().showErrorSnackbar(
              title: AppStrings.snackErrorTitle,
              body: AppStrings.loginSessionError,
            );
          }
        } catch (e) {
          devLog('خطأ أثناء عملية تسجيل الدخول: $e');
          getIt<NavigationService>().showErrorSnackbar(
            title: AppStrings.snackErrorTitle,
            body: AppStrings.loginGenericError,
          );
        }
      }
    });

    return AppGroupedScaffold(
      useAppBar: false,
      body: AuthFlowLayout(
        title: AppStrings.loginWelcome,
        subtitle: AppStrings.loginSubtitle,
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
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _submit(),
                          validator: AuthFormValidators.password,
                        ),
                        const SizedBox(height: 24),
                        AppLoadingButton(
                          isLoading: loginState.isLoading,
                          label: AppStrings.signIn,
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
                      AppStrings.noAccount,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.textMuted,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(
                        AppStrings.createOne,
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
