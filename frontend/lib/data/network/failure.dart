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

extension FailureUserMessage on Failure {
  String get userFacingMessage {
    if (this is NetworkFailure) return NetworkUserMessages.network;
    if (this is TimeoutFailure) return NetworkUserMessages.timeout;
    if (this is ParsingFailure) return NetworkUserMessages.parsing;
    if (this is UnknownFailure) return NetworkUserMessages.unknown;
    if (this is ServerFailure) {
      return NetworkUserMessages.serverPolish(message, code);
    }
    return message;
  }
}
