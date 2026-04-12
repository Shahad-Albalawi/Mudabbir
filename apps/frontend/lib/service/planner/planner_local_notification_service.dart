import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _channelId = 'mudabbir_planner';
const _channelName = 'Mudabbir planner';

/// Local notifications for budget nudges (works without Firebase).
class PlannerLocalNotificationService {
  PlannerLocalNotificationService._();
  static final PlannerLocalNotificationService instance =
      PlannerLocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> initialize() async {
    if (_ready) return;

    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(
      init,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[PlannerNotif] tap ${details.payload}');
      },
    );

    if (Platform.isAndroid) {
      const ch = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Budget reminders and planner nudges',
        importance: Importance.defaultImportance,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(ch);
    }

    _ready = true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_ready) await initialize();
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }
}
