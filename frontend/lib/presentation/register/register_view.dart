import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/presentation/register/register_viewmodel.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/utils/dev_log.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import '../resources/strings_manager.dart';

class RegisterView extends ConsumerWidget {
  RegisterView({super.key});

  // Controllers
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final registerState = ref.watch(registerProvider);
    final registerViewModel = ref.read(registerProvider.notifier);

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

          // 1. Get the user data from the state.
          final userModel = newState.user!;
          final userMap = {'name': userModel.name, 'email': userModel.email};

          // 2. Read the token that the ApiService just saved to Hive.
          final token = getIt<HiveService>().getValue(HiveConstants.savedToken);

          // 3. Ensure token is a non-empty string (same shape as login).
          if (token is String && token.isNotEmpty) {
            await getIt<AuthNotifier>().didLogin(userMap, token);

            // 5. Optional: Force a small delay to ensure GoRouter processes the state change
            await Future.delayed(const Duration(milliseconds: 100));

            devLog('تم التسجيل بنجاح');
          } else {
            // Handle the unlikely case that the token wasn't saved correctly.
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

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                Text(
                  AppStrings.createAccount,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.registerSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                AppCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(24),
                  child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // First Name Field
                            _buildInputField(
                              context: context,
                              label: AppStrings.firstNameLabel,
                              hint: AppStrings.firstNameHint,
                              controller: _firstNameController,
                              icon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الاسم الأول مطلوب';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Email Field
                            _buildInputField(
                              context: context,
                              label: AppStrings.emailLabel,
                              hint: AppStrings.emailHint,
                              controller: _emailController,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'البريد الإلكتروني مطلوب';
                                }
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value)) {
                                  return 'أدخل بريد إلكتروني صحيح';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Password Field
                            _buildInputField(
                              context: context,
                              label: AppStrings.passwordLabel,
                              hint: AppStrings.passwordHint,
                              controller: _passwordController,
                              icon: Icons.lock_outline,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Confirm Password Field
                            _buildInputField(
                              context: context,
                              label: AppStrings.confirmPasswordLabel,
                              hint: AppStrings.confirmPasswordHint,
                              controller: _confirmPasswordController,
                              icon: Icons.lock_outline,
                              obscureText: true,
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'كلمتا المرور غير متطابقتين';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              height: 48,
                              child: registerState.isLoading
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
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          registerViewModel.register(
                                            _firstNameController.text,
                                            _emailController.text,
                                            _passwordController.text,
                                            _confirmPasswordController.text,
                                          );
                                        }
                                      },
                                      child: Text(AppStrings.createAccountButton),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login Link
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppStrings.alreadyHaveAccount,
                            style: TextStyle(
                              fontSize: 16,
                              color: scheme.textMuted,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go('/login');
                            },
                            child: Text(
                              AppStrings.signInLink,
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

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: scheme.textMuted.withValues(alpha: 0.8),
            ),
            prefixIcon: Icon(icon, color: scheme.textMuted, size: 20),
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppLayout.chipRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppLayout.chipRadius),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppLayout.chipRadius),
              borderSide: BorderSide(color: scheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppLayout.chipRadius),
              borderSide: BorderSide(color: scheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppLayout.chipRadius),
              borderSide: BorderSide(color: scheme.error, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
