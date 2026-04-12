import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/persentation/onboarding/onboarding_viewmodel.dart';
import 'package:mudabbir/persentation/onboarding/widgets/animated_background.dart';
import 'package:mudabbir/persentation/onboarding/widgets/modern_bottom_navigation.dart';
import 'package:mudabbir/persentation/onboarding/widgets/onboarding_page_widget.dart';
import 'package:mudabbir/persentation/onboarding/widgets/skip_button.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeController.forward();
    _scaleController.forward();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// Handle skip button or last page
  void _handleSkip() {
    HapticFeedback.lightImpact();

    // Save onboarding completion
    getIt<HiveService>().setValue(HiveConstants.savedFirstTime, true);

    // Trigger GoRouter redirect
    // getIt<AuthNotifier>().refresh();
    context.go('/login');
  }

  void _handlePageChanged(int index) {
    ref.read(onboardingViewModelProvider.notifier).onPageChanged(index);

    // Reset and restart animations for smooth transitions
    _scaleController.reset();
    _scaleController.forward();
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sliderViewObject = ref.watch(onboardingViewModelProvider);
    final viewModel = ref.read(onboardingViewModelProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          SkipButton(onTap: _handleSkip), // Use GoRouter-friendly skip
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated background
          AnimatedBackground(
            currentIndex: sliderViewObject.currentIndex,
            totalPages: sliderViewObject.numOfSlides,
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: sliderViewObject.numOfSlides,
                    onPageChanged: _handlePageChanged,
                    itemBuilder: (context, index) {
                      return FadeTransition(
                        opacity: _fadeController,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _scaleController,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: OnboardingPageWidget(
                            sliderObject: viewModel.slides[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom navigation
                ModernBottomNavigation(
                  sliderViewObject: sliderViewObject,
                  onPrevious: () {
                    HapticFeedback.selectionClick();
                    viewModel.goPrevious();
                    _animateToPage(sliderViewObject.currentIndex);
                  },
                  onNext: () {
                    HapticFeedback.selectionClick();
                    if (sliderViewObject.currentIndex ==
                        sliderViewObject.numOfSlides - 1) {
                      // Last page → complete onboarding
                      _handleSkip();
                    } else {
                      viewModel.goNext();
                      _animateToPage(sliderViewObject.currentIndex);
                    }
                  },
                  onDotTapped: (index) {
                    HapticFeedback.selectionClick();
                    viewModel.onPageChanged(index);
                    _animateToPage(index);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
