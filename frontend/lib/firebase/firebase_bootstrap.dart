import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:mudabbir/firebase/firebase_options.dart';
import 'package:mudabbir/service/notifications/local_notification_service.dart';
import 'package:mudabbir/utils/dev_log.dart';

/// Initializes Firebase when configured (dart-define or flutterfire configure).
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;

  static bool get isReady => _initialized;

  static Future<bool> initialize() async {
    if (_initialized) {
      return true;
    }

    if (!DefaultFirebaseOptions.isConfigured) {
      devLog('[Firebase] Skipped — not configured (see docs/FCM_SETUP.md).');
      return false;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      _initialized = true;
      devLog('[Firebase] Initialized.');
      return true;
    } catch (e, stack) {
      devLog('[Firebase] Init failed: $e\n$stack');
      return false;
    }
  }

  static Future<String?> fetchMessagingToken() async {
    if (!_initialized) {
      return null;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      return await messaging.getToken();
    } catch (e) {
      devLog('[Firebase] getToken failed: $e');
      return null;
    }
  }

  static void listenForegroundMessages() {
    if (!_initialized) {
      return;
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'Mudabbir';
      final body = message.notification?.body ?? '';
      if (body.isEmpty) {
        return;
      }
      LocalNotificationService.instance.show(
        id: message.hashCode,
        title: title,
        body: body,
        channelId: LocalNotificationService.budgetChannelId,
      );
    });
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (DefaultFirebaseOptions.isConfigured) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
