import 'package:mudabbir/service/notifications/local_notification_service.dart';
import 'package:mudabbir/utils/dev_log.dart';

/// Entry point for notification setup (local alerts; FCM can be added later).
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  Future<void> initializeIfConfigured() async {
    await LocalNotificationService.instance.initialize();
    devLog('[Push] Local notification service initialized.');
  }
}
