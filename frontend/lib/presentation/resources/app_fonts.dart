import 'package:mudabbir/presentation/resources/font_manager.dart';

/// Eight (ثمانية) is bundled locally via pubspec for Arabic + English.
class AppFonts {
  AppFonts._();

  static Future<void> ensureLoaded() async {
    assert(FontConstants.fontFamily == FontConstants.eightFamily);
  }
}
