import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/user/user_model.dart';
import 'package:mudabbir/features/auth/models/auth_exception.dart';
import 'package:mudabbir/features/auth/services/auth_service.dart';
import 'package:mudabbir/service/getit_init.dart';

enum AuthScreenOutcome { none, success }

class AuthScreenState {
  const AuthScreenState({
    this.isLoading = false,
    this.failure,
    this.user,
    this.outcome = AuthScreenOutcome.none,
    this.fieldErrors = const {},
  });

  final bool isLoading;
  final Failure? failure;
  final UserModel? user;
  final AuthScreenOutcome outcome;
  final Map<String, String> fieldErrors;

  AuthScreenState copyWith({
    bool? isLoading,
    Failure? failure,
    bool clearFailure = false,
    UserModel? user,
    AuthScreenOutcome? outcome,
    Map<String, String>? fieldErrors,
    bool clearFieldErrors = false,
  }) {
    return AuthScreenState(
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      user: user ?? this.user,
      outcome: outcome ?? this.outcome,
      fieldErrors: clearFieldErrors
          ? const {}
          : (fieldErrors ?? this.fieldErrors),
    );
  }
}

final authScreenProvider =
    StateNotifierProvider<AuthScreenNotifier, AuthScreenState>(
  (ref) => AuthScreenNotifier(),
);

class AuthScreenNotifier extends StateNotifier<AuthScreenState> {
  AuthScreenNotifier({AuthService? authService})
      : _authService = authService ?? getIt<AuthService>(),
        super(const AuthScreenState());

  final AuthService _authService;

  void reset() {
    state = const AuthScreenState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      clearFieldErrors: true,
      outcome: AuthScreenOutcome.none,
    );

    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(
        isLoading: false,
        user: user,
        outcome: AuthScreenOutcome.success,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: e.failure,
        fieldErrors: e.fieldErrors,
      );
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      clearFieldErrors: true,
      outcome: AuthScreenOutcome.none,
    );

    try {
      final user = await _authService.register(
        name,
        email,
        password,
        passwordConfirmation: passwordConfirmation,
      );
      state = state.copyWith(
        isLoading: false,
        user: user,
        outcome: AuthScreenOutcome.success,
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
