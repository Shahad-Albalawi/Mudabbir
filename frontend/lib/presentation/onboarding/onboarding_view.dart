import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/onboarding/onboarding_viewmodel.dart';
import 'package:mudabbir/presentation/onboarding/widgets/animated_dots_indicator.dart';
import 'package:mudabbir/presentation/onboarding/widgets/onboarding_page_widget.dart';
import 'package:mudabbir/presentation/onboarding/widgets/skip_button.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// iOS first-run walkthrough — grouped background, calm typography, one CTA.
class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  late final PageController _pageController;

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

  void _completeOnboarding() {
    HapticFeedback.lightImpact();
    getIt<HiveService>().setValue(HiveConstants.savedFirstTime, true);
    context.go('/login');
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onNext(SliderViewObject state) {
    HapticFeedback.selectionClick();
    if (state.currentIndex == state.numOfSlides - 1) {
      _completeOnboarding();
      return;
    }
    final next = state.currentIndex + 1;
    ref.read(onboardingViewModelProvider.notifier).onPageChanged(next);
    _goToPage(next);
  }

  @override
  Widget build(BuildContext context) {
    final sliderViewObject = ref.watch(onboardingViewModelProvider);
    final viewModel = ref.read(onboardingViewModelProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final isLastPage =
        sliderViewObject.currentIndex == sliderViewObject.numOfSlides - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: scheme.pageBackground,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: SkipButton(onTap: _completeOnboarding),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: sliderViewObject.numOfSlides,
                  onPageChanged: viewModel.onPageChanged,
                  itemBuilder: (context, index) {
                    return OnboardingPageWidget(
                      sliderObject: viewModel.slides[index],
                      isWelcome: index == 0,
                    );
                  },
                ),
              ),
              AnimatedDotsIndicator(
                currentIndex: sliderViewObject.currentIndex,
                totalDots: sliderViewObject.numOfSlides,
                onDotTapped: (index) {
                  HapticFeedback.selectionClick();
                  viewModel.onPageChanged(index);
                  _goToPage(index);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.pageGutter,
                  0,
                  AppLayout.pageGutter,
                  AppLayout.pageGutter,
                ),
                child: FilledButton(
                  onPressed: () => _onNext(sliderViewObject),
                  child: Text(
                    isLastPage
                        ? AppStrings.onboardingGetStarted
                        : (AppStrings.isEnglishLocale ? 'Continue' : 'متابعة'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
