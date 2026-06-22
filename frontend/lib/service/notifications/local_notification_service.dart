import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mudabbir/utils/dev_log.dart';
import 'package:permission_handler/permission_handler.dart';

/// Device-local notifications for budget and goal alerts.
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String budgetChannelId = 'budget_alerts';
  static const String goalChannelId = 'goal_alerts';

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        budgetChannelId,
        'Budget alerts',
        description: 'Warnings when spending nears or exceeds your budget',
        importance: Importance.high,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        goalChannelId,
        'Goal alerts',
        description: 'Celebrations when you complete a savings goal',
        importance: Importance.high,
      ),
    );

    _initialized = true;
    devLog('[Notifications] Local channels ready.');
  }

  Future<bool> requestPermissionIfNeeded() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final result = await Permission.notification.request();
    return result.isGranted;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
  }) async {
    if (!_initialized) await initialize();
    final granted = await requestPermissionIfNeeded();
    if (!granted) {
      devLog('[Notifications] Permission denied — skipped alert.');
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelId == budgetChannelId ? 'Budget alerts' : 'Goal alerts',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.show(id, title, body, details);
  }
}
