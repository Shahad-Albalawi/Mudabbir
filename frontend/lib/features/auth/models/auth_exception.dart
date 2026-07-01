import 'package:mudabbir/data/network/failure.dart';

/// Thrown by [AuthService] when login/register fails.
final class AuthException implements Exception {
  const AuthException(this.failure);

  final Failure failure;

  Map<String, String> get fieldErrors {
    if (failure is ValidationFieldsFailure) {
      return (failure as ValidationFieldsFailure).fieldErrors;
    }
    return const {};
  }

  @override
  String toString() => failure.message;
}
