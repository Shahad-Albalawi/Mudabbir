/// App version — keep in sync with [pubspec.yaml].
abstract final class AppVersion {
  AppVersion._();

  static const String version = '1.0.0';
  static const int build = 1;

  static String get label => '$version+$build';
}
