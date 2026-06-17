import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/onboarding/onboarding_viewmodel.dart';
import 'package:mudabbir/presentation/onboarding/widgets/animated_dots_indicator.dart';
import 'package:mudabbir/presentation/onboarding/widgets/navigation_button.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

class ModernBottomNavigation extends StatelessWidget {
  final SliderViewObject sliderViewObject;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Function(int) onDotTapped;

  const ModernBottomNavigation({
    super.key,
    required this.sliderViewObject,
    required this.onPrevious,
    required this.onNext,
    required this.onDotTapped,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isFirstPage = sliderViewObject.currentIndex == 0;
    final isLastPage =
        sliderViewObject.currentIndex == sliderViewObject.numOfSlides - 1;

    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedDotsIndicator(
            currentIndex: sliderViewObject.currentIndex,
            totalDots: sliderViewObject.numOfSlides,
            onDotTapped: onDotTapped,
          ),
          const SizedBox(height: 32),
          Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: scheme.primary,
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isFirstPage ? 0 : 64,
                  child: isFirstPage
                      ? const SizedBox.shrink()
                      : NavigationButton(
                          icon: Icons.arrow_back_ios,
                          onTap: onPrevious,
                          isEnabled: !isFirstPage,
                        ),
                ),
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isLastPage
                          ? Text(
                              AppStrings.isEnglishLocale
                                  ? 'Get Started'
                                  : 'ابدأ الآن',
                              key: const ValueKey('get_started'),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: scheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            )
                          : Container(
                              key: ValueKey(
                                'progress_${sliderViewObject.currentIndex}',
                              ),
                              width: 120,
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: scheme.onPrimary.withValues(alpha: 0.3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor:
                                    (sliderViewObject.currentIndex + 1) /
                                    sliderViewObject.numOfSlides,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: scheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                NavigationButton(
                  icon: isLastPage ? Icons.check : Icons.arrow_forward_ios,
                  onTap: onNext,
                  isEnabled: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
