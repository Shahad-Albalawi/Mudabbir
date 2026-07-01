import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/features/onboarding/models/ob_slide.dart';
import 'package:mudabbir/features/onboarding/onboarding_prefs.dart';
import 'package:mudabbir/features/onboarding/widgets/onboarding_dots.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

const _slides = <OBSlide>[
  OBSlide(
    icon: Icons.show_chart_rounded,
    bg: AppColors.greenS,
    color: AppColors.green,
    title: 'سيطر على إنفاقك',
    body: 'تتبع دخلك ومصروفاتك مع تصنيفات ذكية',
  ),
  OBSlide(
    icon: Icons.flag_rounded,
    bg: AppColors.goldS,
    color: AppColors.gold,
    title: 'حقّق أهدافك المالية',
    body: 'ضع أهداف ادخار وتابع تقدمك',
  ),
  OBSlide(
    icon: Icons.monitor_heart_rounded,
    bg: AppColors.navySurface,
    color: AppColors.navy1,
    title: 'اعرف صحتك المالية',
    body: 'تحليل ذكي يمنحك درجة صحتك',
  ),
];

/// Premium 3-step onboarding for مدبّر.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.lightImpact();
    await OnboardingPrefs.markOnboarded();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _onNext() {
    HapticFeedback.selectionClick();
    if (_currentPage >= _slides.length - 1) {
      _finishOnboarding();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final isLastPage = _currentPage == _slides.length - 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    final active = index == _currentPage;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: active ? 1.0 : 0.92,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutBack,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOut,
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: slide.bg,
                            ),
                            child: Icon(
                              slide.icon,
                              size: 80,
                              color: slide.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.xxl,
                          ),
                          child: Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            slide.body,
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Spacing.xxl),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _finishOnboarding,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'تخطى',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: OnboardingDots(
                        count: _slides.length,
                        current: _currentPage,
                        activeColor: colors.primary,
                        inactiveColor: colors.border,
                      ),
                    ),
                    TextButton(
                      onPressed: _onNext,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                        ),
                      ),
                      child: Text(
                        isLastPage ? 'ابدأ الآن' : 'التالي',
                        style: textTheme.labelLarge?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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
