import 'package:mudabbir/presentation/resources/network_messages.dart';

class Failure {
  final int code;
  final String message;
  const Failure(this.code, this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(-1, message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(String message) : super(-2, message);
}

class ParsingFailure extends Failure {
  const ParsingFailure(String message) : super(-3, message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.code, super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(-4, message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(-5, message);
}

/// Laravel 422 field errors keyed by input name (`email`, `password`, …).
class ValidationFieldsFailure extends Failure {
  ValidationFieldsFailure(this.fieldErrors, {String message = 'validation'})
      : super(422, message);

  final Map<String, String> fieldErrors;
}

class BudgetExceededFailure extends Failure {
  final double budgetRemaining;
  const BudgetExceededFailure(String message, {this.budgetRemaining = 0})
      : super(-6, message);
}

extension FailureUserMessage on Failure {
  String get userFacingMessage {
    if (this is NetworkFailure) return NetworkUserMessages.network;
    if (this is TimeoutFailure) return NetworkUserMessages.timeout;
    if (this is ParsingFailure) return NetworkUserMessages.parsing;
    if (this is UnknownFailure) return NetworkUserMessages.unknown;
    if (this is ValidationFieldsFailure) return message;
    if (this is ValidationFailure) return message;
    if (this is BudgetExceededFailure) return message;
    if (this is ServerFailure) {
      return NetworkUserMessages.serverPolish(message, code);
    }
    return message;
  }
}
