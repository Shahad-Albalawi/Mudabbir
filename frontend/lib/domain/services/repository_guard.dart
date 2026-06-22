import 'package:dartz/dartz.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/data/network/api_exception.dart';

/// Typed failure for repository layer boundaries.
class RepositoryException implements Exception {
  final String message;
  final Object? cause;

  const RepositoryException(this.message, [this.cause]);

  @override
  String toString() => message;
}

/// Wraps repository calls with consistent try/catch → [Either].
Future<Either<Failure, T>> guardRepository<T>(
  Future<T> Function() action, {
  String fallbackMessage = 'Operation failed',
}) async {
  try {
    return Right(await action());
  } on RepositoryException catch (e) {
    return Left(UnknownFailure(e.message));
  } catch (e) {
    return Left(UnknownFailure(fallbackMessage));
  }
}

/// Synchronous variant for pure transforms.
Either<Failure, T> guardRepositorySync<T>(
  T Function() action, {
  String fallbackMessage = 'Operation failed',
}) {
  try {
    return Right(action());
  } on RepositoryException catch (e) {
    return Left(UnknownFailure(e.message));
  } catch (_) {
    return Left(UnknownFailure(fallbackMessage));
  }
}

/// Wraps offline-first sync calls — preserves [ApiException], maps others.
Future<T> guardSyncedOperation<T>(
  Future<T> Function() action, {
  String fallbackMessage = 'Sync failed',
}) async {
  try {
    return await action();
  } on ApiException {
    rethrow;
  } on RepositoryException catch (e) {
    throw ApiException(message: e.message, statusCode: null);
  } catch (_) {
    throw ApiException(message: fallbackMessage, statusCode: null);
  }
}
