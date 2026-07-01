import 'package:http/http.dart' as http;
import 'package:mudabbir/constants/api_constants.dart';
import 'package:mudabbir/utils/dev_log.dart';

/// Pings the production API health endpoint to wake Render free-tier instances.
class BackendWarmupService {
  BackendWarmupService._();

  /// Render cold starts can take 30–60s after idle sleep (~15 min).
  static const Duration _coldStartTimeout = Duration(seconds: 45);

  static Future<void> wakeRenderBackend() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/health');

    try {
      final response = await http.get(uri).timeout(_coldStartTimeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        devLog('[Mudabbir] Backend warm-up ✓ (${response.statusCode})');
      } else {
        devLog('[Mudabbir] Backend warm-up ✗ HTTP ${response.statusCode}');
      }
    } catch (e) {
      devLog('[Mudabbir] Backend warm-up ✗ $e');
    }
  }
}
