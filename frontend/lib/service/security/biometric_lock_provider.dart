import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/service/security/biometric_lock_preferences.dart';
import 'package:mudabbir/service/security/biometric_lock_service.dart';

final biometricLockServiceProvider = Provider<BiometricLockService>(
  (ref) => BiometricLockService(),
);

class BiometricLockState {
  const BiometricLockState({
    this.enabled = false,
    this.locked = false,
    this.availability = BiometricAvailability.notSupported,
    this.loaded = false,
  });

  final bool enabled;
  final bool locked;
  final BiometricAvailability availability;
  final bool loaded;

  BiometricLockState copyWith({
    bool? enabled,
    bool? locked,
    BiometricAvailability? availability,
    bool? loaded,
  }) {
    return BiometricLockState(
      enabled: enabled ?? this.enabled,
      locked: locked ?? this.locked,
      availability: availability ?? this.availability,
      loaded: loaded ?? this.loaded,
    );
  }
}

final biometricLockProvider =
    StateNotifierProvider<BiometricLockNotifier, BiometricLockState>(
  (ref) => BiometricLockNotifier(
    ref: ref,
    service: ref.watch(biometricLockServiceProvider),
  ),
);

class BiometricLockNotifier extends StateNotifier<BiometricLockState>
    with WidgetsBindingObserver {
  BiometricLockNotifier({
    required Ref ref,
    required BiometricLockService service,
  })  : _ref = ref,
        _service = service,
        super(const BiometricLockState()) {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  final Ref _ref;
  final BiometricLockService _service;

  AuthNotifier get _auth => _ref.read(authNotifierProvider);

  Future<void> _initialize() async {
    final enabled = await BiometricLockPreferences.isEnabled();
    final availability = await _service.checkAvailability();
    final shouldLock = enabled && _auth.isLoggedIn;
    state = state.copyWith(
      enabled: enabled,
      loaded: true,
      availability: availability,
      locked: shouldLock,
    );

    if (shouldLock) {
      await unlock();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lockState = this.state;
    if (!lockState.enabled || !_auth.isLoggedIn) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      this.state = lockState.copyWith(locked: true);
    }

    if (state == AppLifecycleState.resumed && this.state.locked) {
      unlock();
    }
  }

  Future<bool> setEnabled(bool enabled) async {
    final availability = await _service.checkAvailability();
    state = state.copyWith(availability: availability);

    if (enabled && availability != BiometricAvailability.available) {
      return false;
    }

    if (enabled) {
      final ok = await _service.authenticate(
        reason: AppStrings.biometricUnlockReason,
      );
      if (!ok) return false;
    }

    await BiometricLockPreferences.setEnabled(enabled);
    state = state.copyWith(enabled: enabled, locked: false);
    return true;
  }

  Future<bool> unlock() async {
    if (!state.enabled || !_auth.isLoggedIn) {
      state = state.copyWith(locked: false);
      return true;
    }

    final ok = await _service.authenticate(
      reason: AppStrings.biometricUnlockReason,
    );
    if (ok) {
      state = state.copyWith(locked: false);
    }
    return ok;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
