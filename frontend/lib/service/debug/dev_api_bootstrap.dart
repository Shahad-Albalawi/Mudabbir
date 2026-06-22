import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mudabbir/constants/api_constants.dart';
import 'package:mudabbir/utils/api_session.dart';
import 'package:mudabbir/utils/dev_log.dart';

/// Debug-only: log API target and verify local backend reachability.
class DevApiBootstrap {
  DevApiBootstrap._();

  static bool? lastHealthOk;
  static String get apiBase => ApiConstants.baseUrl;

  static Future<void> logAndProbe() async {
    if (!kDebugMode) return;

    devLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    devLog('[Mudabbir] API base → ${ApiConstants.baseUrl}');
    devLog('[Mudabbir] API v1   → ${ApiConstants.apiV1Base}');
    devLog('[Mudabbir] After UI edits press R (hot RESTART), not r');
    devLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/health');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));
      lastHealthOk = res.statusCode == 200;
      devLog(
        lastHealthOk == true
            ? '[Mudabbir] Backend health ✓ OK'
            : '[Mudabbir] Backend health ✗ HTTP ${res.statusCode}',
      );
    } catch (e) {
      lastHealthOk = false;
      devLog('[Mudabbir] Backend health ✗ unreachable ($e)');
      devLog('[Mudabbir] Start: scripts/start-backend.ps1');
    }

    final session = await hasApiSession();
    if (!session) {
      devLog('[Mudabbir] No login token — register/login for sync, AI, challenges');
    }
  }
}
