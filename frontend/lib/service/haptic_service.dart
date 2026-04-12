import 'package:flutter/services.dart';

/// iOS-style haptic feedback for key user actions.
/// Enhances UX with tactile response on taps, selections, and success.
class HapticService {
  HapticService._();
  static final HapticService _instance = HapticService._();
  static HapticService get instance => _instance;

  /// Light tap - for buttons, list items, nav taps
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium tap - for primary actions (add expense, add income)
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy tap - for significant actions (goal achieved, delete)
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click - for toggles, segmented controls
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Success - for completed actions
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Error/warning
  static void warning() {
    HapticFeedback.heavyImpact();
  }
}
