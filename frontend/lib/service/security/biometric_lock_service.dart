import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

enum BiometricAvailability {
  available,
  notEnrolled,
  notSupported,
  temporarilyUnavailable,
}

class BiometricLockService {
  BiometricLockService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<BiometricAvailability> checkAvailability() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        return BiometricAvailability.notSupported;
      }

      final canCheck = await _auth.canCheckBiometrics;
      final biometrics = await _auth.getAvailableBiometrics();
      if (!canCheck || biometrics.isEmpty) {
        return BiometricAvailability.notEnrolled;
      }

      return BiometricAvailability.available;
    } on PlatformException {
      return BiometricAvailability.temporarilyUnavailable;
    }
  }

  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  static String messageForAvailability(BiometricAvailability availability) {
    return switch (availability) {
      BiometricAvailability.available => AppStrings.biometricAvailable,
      BiometricAvailability.notEnrolled => AppStrings.biometricNotEnrolled,
      BiometricAvailability.notSupported => AppStrings.biometricNotSupported,
      BiometricAvailability.temporarilyUnavailable =>
        AppStrings.biometricUnavailable,
    };
  }
}
