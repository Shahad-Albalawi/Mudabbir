import 'package:mudabbir/service/haptic_service.dart';

/// Short alias for tactile feedback — iOS-style impacts.
abstract final class AppHaptics {
  AppHaptics._();

  static void light() => HapticService.light();
  static void medium() => HapticService.medium();
  static void heavy() => HapticService.heavy();
  static void selection() => HapticService.selection();
  static void success() => HapticService.success();
  static void warning() => HapticService.warning();
}

typedef Haptics = AppHaptics;
