import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceUtils {
  static final _storage = FlutterSecureStorage();
  static const _key = 'persistent_device_uuid';

  static Future<String> getPersistentUUID() async {
    // Check if UUID already exists in secure storage
    String? existingUUID = await _storage.read(key: _key);
    if (existingUUID != null) return existingUUID;

    // Try to get platform-specific ID
    String deviceId = "unknown";

    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "unknown";
      }
    } catch (e) {
      // fallback to generated UUID
      debugPrint("Error fetching device ID: $e");
    }

    // If platform ID unavailable, generate a new UUID
    if (deviceId == "unknown") {
      deviceId = Uuid().v4();
    }

    // Save it in secure storage
    await _storage.write(key: _key, value: deviceId);

    return deviceId;
  }
}
