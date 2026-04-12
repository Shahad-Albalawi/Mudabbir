import 'package:mudabbir/utils/dev_log.dart';

/// Placeholder for any future server-driven push channel.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  Future<void> initializeIfConfigured() async {
    devLog('[Push] Server push not configured (no-op).');
  }
}
