// ignore_for_file: lines_longer_than_80_chars
// --- Firebase configuration stub.
// Run: `dart pub global activate flutterfire_cli` then `flutterfire configure`
// This replaces apiKey / appId / projectId with your real project values.
// Until then, [DefaultFirebaseOptions.isConfigured] is false and push is skipped.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  /// True after you run `flutterfire configure` and real keys are present.
  static bool get isConfigured {
    return !_placeholderKey(_android.apiKey) && !_placeholderKey(_ios.apiKey);
  }

  static bool _placeholderKey(String k) {
    return k.isEmpty || k.startsWith('REPLACE_');
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Add web options via flutterfire configure if needed.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        return _ios;
      default:
        throw UnsupportedError(
          'Firebase push is configured for Android & iOS only.',
        );
    }
  }

  static const FirebaseOptions _android = FirebaseOptions(
    apiKey: 'REPLACE_ANDROID_API_KEY',
    appId: 'REPLACE_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_SENDER_ID',
    projectId: 'REPLACE_PROJECT_ID',
    storageBucket: 'REPLACE_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions _ios = FirebaseOptions(
    apiKey: 'REPLACE_IOS_API_KEY',
    appId: 'REPLACE_IOS_APP_ID',
    messagingSenderId: 'REPLACE_SENDER_ID',
    projectId: 'REPLACE_PROJECT_ID',
    storageBucket: 'REPLACE_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.mudabbir',
  );
}
