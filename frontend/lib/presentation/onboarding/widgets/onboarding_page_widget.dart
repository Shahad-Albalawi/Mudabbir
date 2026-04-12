import 'package:mudabbir/presentation/onboarding/onboarding_viewmodel.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:flutter/material.dart';

class OnboardingPageWidget extends StatefulWidget {
  final SliderObject sliderObject;

  const OnboardingPageWidget({super.key, required this.sliderObject});

  @override
  State<OnboardingPageWidget> createState() => _OnboardingPageWidgetState();
}

class _OnboardingPageWidgetState extends State<OnboardingPageWidget>
    with TickerProviderStateMixin {
  late final AnimationController _contentController;
  late final AnimationController _imageController;
  late final Animation<double> _titleAnimation;
  late final Animation<double> _subtitleAnimation;
  late final Animation<double> _imageAnimation;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<Offset> _subtitleSlideAnimation;

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Staggered animations for content
    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _imageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.elasticOut),
    );

    // Slide animations
    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    // Start animations
    _contentController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _imageController.forward();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Title with animation
          SlideTransition(
            position: _titleSlideAnimation,
            child: FadeTransition(
              opacity: _titleAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.sliderObject.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle with animation
          SlideTransition(
            position: _subtitleSlideAnimation,
            child: FadeTransition(
              opacity: _subtitleAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.sliderObject.subTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 60),

          // Image with advanced animation
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _imageAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _imageAnimation.value,
                    child: Transform.rotate(
                      angle: (1 - _imageAnimation.value) * 0.1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: ColorManager.shadowLight,
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: widget.sliderObject.icon != null
                            ? Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: ColorManager.primaryWithOpacity10,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Icon(
                                    widget.sliderObject.icon,
                                    size: 80,
                                    color: ColorManager.primary,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
