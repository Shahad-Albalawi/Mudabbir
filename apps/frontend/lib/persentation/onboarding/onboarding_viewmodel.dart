import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/persentation/resources/strings_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingViewModelProvider =
    StateNotifierProvider<OnBoardingViewModel, SliderViewObject>(
      (ref) => OnBoardingViewModel(),
    );

class OnBoardingViewModel extends StateNotifier<SliderViewObject> {
  late final List<SliderObject> _list;
  int _currentIndex = 0;

  OnBoardingViewModel()
      : super(
        SliderViewObject(
          SliderObject(
            AppStrings.onBoardingTitle1,
            AppStrings.onBoardingSubTitle1,
            icon: CupertinoIcons.creditcard_fill,
          ),
          4,
          0,
        ),
      ) {
    _list = _getSliderData();
    _updateState(); // set the initial slide
  }
  List<SliderObject> get slides => _list; // public getter
  // Load all slides
  List<SliderObject> _getSliderData() => [
    SliderObject(
      AppStrings.onBoardingTitle1,
      AppStrings.onBoardingSubTitle1,
      icon: CupertinoIcons.creditcard_fill,
    ),
    SliderObject(
      AppStrings.onBoardingTitle2,
      AppStrings.onBoardingSubTitle2,
      icon: CupertinoIcons.chart_pie_fill,
    ),
    SliderObject(
      AppStrings.onBoardingTitle3,
      AppStrings.onBoardingSubTitle3,
      icon: CupertinoIcons.chat_bubble_2_fill,
    ),
    SliderObject(
      AppStrings.onBoardingTitle4,
      AppStrings.onBoardingSubTitle4,
      icon: CupertinoIcons.flag_fill,
    ),
  ];

  void goNext() {
    _currentIndex = (_currentIndex + 1) % _list.length;
    _updateState();
  }

  void goPrevious() {
    _currentIndex = (_currentIndex - 1 + _list.length) % _list.length;
    _updateState();
  }

  void onPageChanged(int index) {
    _currentIndex = index;
    _updateState();
  }

  void _updateState() {
    state = SliderViewObject(_list[_currentIndex], _list.length, _currentIndex);
  }
}

// SliderViewObject and SliderObject remain the same
class SliderViewObject {
  final SliderObject sliderObject;
  final int numOfSlides;
  final int currentIndex;

  SliderViewObject(this.sliderObject, this.numOfSlides, this.currentIndex);
}

class SliderObject {
  final String title;
  final String subTitle;
  final IconData? icon;

  SliderObject(this.title, this.subTitle, {this.icon});
}
