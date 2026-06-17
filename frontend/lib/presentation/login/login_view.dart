import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/presentation/login/login_viewmodel.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/utils/dev_log.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import '../resources/strings_manager.dart';

class LoginView extends ConsumerWidget {
  LoginView({super.key});
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final loginState = ref.watch(loginProvider);
    final loginViewModel = ref.read(loginProvider.notifier);

    // Updated listener in LoginView
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

          // 1. Get the user data from the state.
          final userModel = newState.user!;
          final userMap = {'name': userModel.name, 'email': userModel.email};

          // 2. Read the token that the ApiService just saved to Hive.
          final token = getIt<HiveService>().getValue(HiveConstants.savedToken);

          // 3. Ensure we have a non-empty string token (Hive is dynamic).
          if (token is String && token.isNotEmpty) {
            await getIt<AuthNotifier>().didLogin(userMap, token);

            // 5. Optional: Force a small delay to ensure GoRouter processes the state change
            await Future.delayed(const Duration(milliseconds: 100));

            devLog('تم تسجيل الدخول بنجاح');
          } else {
            // Handle the unlikely case that the token wasn't saved correctly.
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

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Icon(
                  CupertinoIcons.creditcard,
                  size: 48,
                  color: scheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.loginWelcome,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.loginSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                AppCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(24),
                  child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.emailLabel,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: AppStrings.emailHint,
                                    hintStyle: TextStyle(
                                      color: scheme.textMuted
                                          .withValues(alpha: 0.7),
                                    ),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(12),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: scheme.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.email_outlined,
                                        color: scheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: scheme.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppLayout.chipRadius,
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppLayout.chipRadius,
                                      ),
                                      borderSide: BorderSide(
                                        color: scheme.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppLayout.chipRadius,
                                      ),
                                      borderSide: BorderSide(
                                        color: scheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppLayout.chipRadius,
                                      ),
                                      borderSide: BorderSide(
                                        color: scheme.error,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'البريد الإلكتروني مطلوب';
                                    }
                                    if (!RegExp(
                                      r'\S+@\S+\.\S+',
                                    ).hasMatch(value)) {
                                      return 'أدخل بريد إلكتروني صحيح';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Password Field
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.passwordLabel,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    hintText: AppStrings.passwordHint,
                                    hintStyle: TextStyle(
                                      color: scheme.textMuted
                                          .withValues(alpha: 0.7),
                                    ),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(12),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: scheme.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.lock_outline,
                                        color: scheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: scheme.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppLayout.chipRadius,
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppLayout.chipRadius,
                                      ),
                                      borderSide: BorderSide(
                                        color: scheme.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppLayout.chipRadius,
                                      ),
                                      borderSide: BorderSide(
                                        color: scheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppLayout.chipRadius,
                                      ),
                                      borderSide: BorderSide(
                                        color: scheme.error,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'كلمة المرور مطلوبة';
                                    }
                                    if (value.length < 6) {
                                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              height: 48,
                              child: loginState.isLoading
                                  ? Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: scheme.primary,
                                        ),
                                      ),
                                    )
                                  : FilledButton(
                                      onPressed: () async {
                                        if (formKey.currentState!.validate()) {
                                          await loginViewModel.login(
                                            emailController.text,
                                            passwordController.text,
                                          );
                                        }
                                      },
                                      child: Text(AppStrings.signIn),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Register Link
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.noAccount,
                            style: TextStyle(
                              fontSize: 16,
                              color: scheme.textMuted,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go('/register');
                            },
                            child: Text(
                              AppStrings.createOne,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
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
          ),
    );
  }
}
