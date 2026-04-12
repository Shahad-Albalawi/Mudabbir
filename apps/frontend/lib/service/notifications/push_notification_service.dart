import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mudabbir/firebase_options.dart';

// --- FCM + local notifications. No-op until [DefaultFirebaseOptions.isConfigured].
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final _local = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> initializeIfConfigured() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      debugPrint(
        '[Push] Skipped — run flutterfire configure (see README at repo root).',
      );
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _local.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[Push] Tapped notification: ${details.payload}');
      },
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'mudabbir_default',
        'Mudabbir updates',
        description: 'Budget reminders and challenge updates',
        importance: Importance.high,
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    final messaging = FirebaseMessaging.instance;
    await messaging.setAutoInitEnabled(true);

    if (Platform.isIOS) {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    }

    FirebaseMessaging.onMessage.listen(_showForeground);

    _ready = true;
    final token = await messaging.getToken();
    debugPrint('[Push] FCM token: $token');
  }

  Future<void> _showForeground(RemoteMessage message) async {
    if (!_ready) return;
    final n = message.notification;
    if (n == null) return;

    await _local.show(
      id: n.hashCode,
      title: n.title,
      body: n.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'mudabbir_default',
          'Mudabbir updates',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.messageId,
    );
  }
}

/// Register in main.dart only when [DefaultFirebaseOptions.isConfigured].
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('[Push][bg] ${message.messageId}');
}
