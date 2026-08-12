import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/core/providers/provider_reader.dart';

bool stringsSourceIsEnglish() {
  try {
    return readApp(appLanguageControllerProvider).locale.languageCode == 'en';
  } catch (_) {
    return false;
  }
}
