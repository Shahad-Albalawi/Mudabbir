import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase options — replace by running `flutterfire configure`, or pass
/// `--dart-define=FIREBASE_PROJECT_ID=...` etc. See docs/FCM_SETUP.md.
class DefaultFirebaseOptions {
  static bool get isConfigured {
    if (kIsWeb) {
      return _projectId.isNotEmpty && _webAppId.isNotEmpty;
    }
    return _projectId.isNotEmpty &&
        _androidAppId.isNotEmpty &&
        _androidApiKey.isNotEmpty;
  }

  static const String _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String _androidApiKey =
      String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
  static const String _androidAppId =
      String.fromEnvironment('FIREBASE_ANDROID_APP_ID');
  static const String _iosApiKey = String.fromEnvironment('FIREBASE_IOS_API_KEY');
  static const String _iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
  static const String _webApiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
  static const String _webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const String _messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');

  static FirebaseOptions get currentPlatform {
    if (!isConfigured) {
      throw StateError(
        'Firebase is not configured. Run flutterfire configure or pass FIREBASE_* dart-defines.',
      );
    }

    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: _webApiKey,
        appId: _webAppId,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: _androidApiKey,
          appId: _androidAppId,
          messagingSenderId: _messagingSenderId,
          projectId: _projectId,
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return FirebaseOptions(
          apiKey: _iosApiKey,
          appId: _iosAppId,
          messagingSenderId: _messagingSenderId,
          projectId: _projectId,
        );
      default:
        throw UnsupportedError('Firebase is not supported on this platform.');
    }
  }
}
