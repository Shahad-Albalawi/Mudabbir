import 'package:mudabbir/presentation/resources/font_manager.dart';

/// Thmanyah is bundled via pubspec for Arabic + English.
class AppFonts {
  AppFonts._();

  static Future<void> ensureLoaded() async {
    // Fonts are declared in pubspec; hook kept for startup symmetry.
    assert(FontConstants.fontFamily == FontConstants.thmanyahFamily);
  }
}
