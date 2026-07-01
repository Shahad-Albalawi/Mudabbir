/// Remote backend HTTP client.
///
/// The app uses a **Laravel REST API** (not Supabase). This file keeps the
/// layout path from the target architecture and re-exports [DioClient].
library;

export 'package:mudabbir/data/network/dio_client.dart';

import 'package:mudabbir/data/network/dio_client.dart' show DioClient;

/// Alias for the planned folder name — use [DioClient] in new code.
typedef SupabaseClient = DioClient;
