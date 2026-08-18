import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mudabbir/core/providers/provider_reader.dart';
import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/firebase/firebase_bootstrap.dart';
import 'package:mudabbir/service/notifications/local_notification_service.dart';
import 'package:mudabbir/utils/dev_log.dart';
import 'package:permission_handler/permission_handler.dart';

/// Push: local notifications always; FCM when Firebase is configured.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  String? _cachedToken;

  String? get cachedToken => _cachedToken;

  Future<void> initializeIfConfigured() async {
    await LocalNotificationService.instance.initialize();
    await _requestNotificationPermission();

    if (await FirebaseBootstrap.initialize()) {
      FirebaseBootstrap.listenForegroundMessages();
      _cachedToken = await FirebaseBootstrap.fetchMessagingToken();
      if (_cachedToken != null && _cachedToken!.isNotEmpty) {
        devLog('[Push] FCM token acquired.');
        await syncTokenWithBackend();
        return;
      }
    }

    _cachedToken = const String.fromEnvironment('FCM_TEST_TOKEN');
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      devLog('[Push] Using FCM_TEST_TOKEN from dart-define.');
      await syncTokenWithBackend();
    } else {
      devLog('[Push] No FCM token — configure Firebase (docs/FCM_SETUP.md).');
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (kIsWeb) return;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
        }
      }
    } catch (e) {
      devLog('[Push] Notification permission request skipped: $e');
    }
  }

  Future<void> syncTokenWithBackend() async {
    final token = _cachedToken;
    if (token == null || token.isEmpty) return;

    try {
      final auth = readApp(authNotifierProvider);
      if (!auth.isLoggedIn) return;

      final platform = _platformLabel();
      await readApp(notificationApiServiceProvider).registerDeviceToken(
        token: token,
        platform: platform,
      );
      devLog('[Push] Device token registered with backend.');
    } catch (e, stack) {
      devLog('[Push] Token registration failed: $e\n$stack');
    }
  }

  Future<void> unregisterFromBackend() async {
    final token = _cachedToken;
    if (token == null || token.isEmpty) return;

    try {
      await readApp(notificationApiServiceProvider).unregisterDeviceToken(token);
    } catch (e) {
      devLog('[Push] Token unregister failed: $e');
    }
  }

  String? _platformLabel() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return Platform.operatingSystem;
  }
}
