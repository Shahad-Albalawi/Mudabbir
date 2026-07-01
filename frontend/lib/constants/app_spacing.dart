import 'package:mudabbir/constants/app_dimensions.dart';

export 'package:mudabbir/constants/app_dimensions.dart' show Spacing;

/// Legacy spacing tokens — prefer [Spacing].
abstract final class AppSpacing {
  AppSpacing._();

  static const double xs = Spacing.xs;
  static const double sm = Spacing.sm;
  static const double md = Spacing.md;
  static const double lg = Spacing.lg;
  static const double xl = Spacing.xl;
  static const double xxl = Spacing.xxl;
  static const double xxxl = Spacing.xxxl;
  static const double huge = Spacing.huge;
  static const double buttonHeight = Spacing.buttonHeight;

  @Deprecated('Use md')
  static const double smd = md;
}
