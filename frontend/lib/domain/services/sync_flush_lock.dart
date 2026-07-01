import 'dart:async';

import 'package:mudabbir/data/network/api_exception.dart';

/// Prevents concurrent pending-op flush runs from racing.
class SyncFlushLock {
  SyncFlushLock._();

  static Future<void>? _inFlight;

  static Future<T> run<T>(Future<T> Function() action) async {
    while (_inFlight != null) {
      await _inFlight;
    }
    final done = Completer<void>();
    _inFlight = done.future;
    try {
      return await action();
    } finally {
      _inFlight = null;
      if (!done.isCompleted) done.complete();
    }
  }
}

/// Whether a failed pending op should stay queued for a later flush.
bool shouldRetainPendingOp({
  required ApiException error,
  required String? opType,
}) {
  if (error.isNetworkError) return true;

  // Resource already removed server-side — drop stale delete ops.
  if (error.statusCode == 404) {
    switch (opType) {
      case 'delete':
      case 'delete_goal':
      case 'delete_budget':
        return false;
    }
  }

  // Validation/conflict/server errors: keep queued so data is not silently lost.
  return true;
}
