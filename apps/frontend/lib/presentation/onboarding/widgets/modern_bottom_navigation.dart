import 'package:mudabbir/presentation/onboarding/onboarding_viewmodel.dart';
import 'package:mudabbir/presentation/onboarding/widgets/animated_dots_indicator.dart';
import 'package:mudabbir/presentation/onboarding/widgets/navigation_button.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:flutter/material.dart';

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
    final isFirstPage = sliderViewObject.currentIndex == 0;
    final isLastPage =
        sliderViewObject.currentIndex == sliderViewObject.numOfSlides - 1;

    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots indicator
          AnimatedDotsIndicator(
            currentIndex: sliderViewObject.currentIndex,
            totalDots: sliderViewObject.numOfSlides,
            onDotTapped: onDotTapped,
          ),

          const SizedBox(height: 32),

          // Navigation buttons
          Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: ColorManager.primary,
              boxShadow: [
                BoxShadow(
                  color: ColorManager.primary.withValues(alpha: 0.16),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Previous button
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

                // Center space with progress
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: isLastPage
                          ? Text(
                              'Get Started',
                              key: const ValueKey('get_started'),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
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
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor:
                                    (sliderViewObject.currentIndex + 1) /
                                    sliderViewObject.numOfSlides,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: ColorManager.white,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),

                // Next button
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
