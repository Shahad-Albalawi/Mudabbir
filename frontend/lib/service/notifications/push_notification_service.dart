import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mudabbir/core/providers/provider_reader.dart';
import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/service/notifications/local_notification_service.dart';
import 'package:mudabbir/utils/dev_log.dart';

/// Push setup: local notifications always; FCM token registration when available.
///
/// Full FCM requires Firebase config files — see `docs/FCM_SETUP.md`.
/// For manual testing, pass `--dart-define=FCM_TEST_TOKEN=...`.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  String? _cachedToken;

  String? get cachedToken => _cachedToken;

  Future<void> initializeIfConfigured() async {
    await LocalNotificationService.instance.initialize();
    _cachedToken = const String.fromEnvironment('FCM_TEST_TOKEN');
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      devLog('[Push] Using FCM_TEST_TOKEN from dart-define.');
      await syncTokenWithBackend();
    } else {
      devLog('[Push] Local notifications ready. Add Firebase for live FCM tokens.');
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
