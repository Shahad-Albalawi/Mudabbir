import 'package:flutter/foundation.dart';

/// Logs only in debug builds (no console noise in release / store builds).
void devLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
