import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/user/user_model.dart';
import 'package:mudabbir/features/auth/models/auth_exception.dart';
import 'package:mudabbir/features/auth/services/auth_service.dart';
import 'package:mudabbir/core/providers/app_providers.dart';

enum PasswordResetOutcome { none, codeSent, resetSuccess }

class PasswordResetState {
  const PasswordResetState({
    this.isLoading = false,
    this.failure,
    this.fieldErrors = const {},
    this.outcome = PasswordResetOutcome.none,
    this.email,
    this.user,
  });

  final bool isLoading;
  final Failure? failure;
  final Map<String, String> fieldErrors;
  final PasswordResetOutcome outcome;
  final String? email;
  final UserModel? user;

  PasswordResetState copyWith({
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
    Map<String, String>? fieldErrors,
    bool clearFieldErrors = false,
    PasswordResetOutcome? outcome,
    String? email,
    UserModel? user,
  }) {
    return PasswordResetState(
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      fieldErrors: clearFieldErrors
          ? const {}
          : (fieldErrors ?? this.fieldErrors),
      outcome: outcome ?? this.outcome,
      email: email ?? this.email,
      user: user ?? this.user,
    );
  }
}

final passwordResetProvider =
    StateNotifierProvider<PasswordResetNotifier, PasswordResetState>(
  (ref) => PasswordResetNotifier(authService: ref.watch(authServiceProvider)),
);

class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  PasswordResetNotifier({required AuthService authService})
      : _authService = authService,
        super(const PasswordResetState());

  final AuthService _authService;

  void reset() {
    state = const PasswordResetState();
  }

  Future<void> requestCode(String email) async {
    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      clearFieldErrors: true,
      outcome: PasswordResetOutcome.none,
    );

    try {
      await _authService.forgotPassword(email);
      state = state.copyWith(
        isLoading: false,
        email: email.trim(),
        outcome: PasswordResetOutcome.codeSent,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: e.failure,
        fieldErrors: e.fieldErrors,
      );
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      clearFieldErrors: true,
      outcome: PasswordResetOutcome.none,
    );

    try {
      final user = await _authService.resetPassword(
        email: email,
        code: code,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = state.copyWith(
        isLoading: false,
        user: user,
        outcome: PasswordResetOutcome.resetSuccess,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: e.failure,
        fieldErrors: e.fieldErrors,
      );
    }
  }
}
