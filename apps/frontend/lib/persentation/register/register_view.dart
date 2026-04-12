import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/persentation/register/register_viewmodel.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import '../resources/color_manager.dart';
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

            debugPrint('تم التسجيل بنجاح');
          } else {
            // Handle the unlikely case that the token wasn't saved correctly.
            getIt<NavigationService>().showErrorSnackbar(
              title: AppStrings.snackErrorTitle,
              body: AppStrings.loginSessionError,
            );
          }
        } catch (e) {
          debugPrint('خطأ أثناء عملية التسجيل: $e');
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
        child: Stack(
          children: [
            _buildModernBackground(context),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                // App Logo/Icon & Header
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      // Container(
                      //   width: 90,
                      //   height: 90,
                      //   decoration: BoxDecoration(
                      //     gradient: LinearGradient(
                      //       colors: [
                      //         ColorManager.primary,
                      //         ColorManager.darkPrimary,
                      //       ],
                      //     ),
                      //     borderRadius: BorderRadius.circular(22),
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: ColorManager.primary.withOpacity(0.3),
                      //         blurRadius: 20,
                      //         offset: const Offset(0, 10),
                      //       ),
                      //     ],
                      //   ),
                      //   child: SvgPicture.asset(
                      //     ImageAssets.onBoardingLogo2,
                      //     fit: BoxFit.contain,
                      //     width: 50,
                      //     height: 50,
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.createAccount,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.registerSubtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Register Form Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: scheme.outline.withValues(alpha: 0.25)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
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

                        // Register Button
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.24),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: registerState.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ColorManager.white,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
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
                                  child: Text(
                                    AppStrings.createAccountButton,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: ColorManager.white,
                                    ),
                                  ),
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
                              color: scheme.onSurfaceVariant,
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
        ],
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
              color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorManager.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: ColorManager.primary, size: 20),
            ),
            filled: true,
            fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: 0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: ColorManager.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: ColorManager.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: ColorManager.error, width: 2),
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

  Widget _buildModernBackground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned(
          top: -70,
          left: -50,
          child: Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -90,
          right: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: scheme.secondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
