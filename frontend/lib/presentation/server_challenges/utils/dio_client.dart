import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mudabbir/constants/api_constants.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';

class DioClient {
  static String get baseUrl => ApiConstants.apiV1Base;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Some CDNs block anonymous clients; helps reach Laravel Cloud from devices.
          'User-Agent': 'MudabbirFlutter/1.0',
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor());
    if (kDebugMode) {
      _dio.interceptors.add(_LoggingInterceptor());
    }
  }

  Dio get dio => _dio;
}

// Auth Interceptor - Adds Bearer token to all requests
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getIt<HiveService>().getValue(HiveConstants.savedToken);
    if (token is String && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      unawaited(getIt<AuthNotifier>().didLogout());
    }

    handler.next(err);
  }
}

// Logging Interceptor - For debugging (optional)
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🌐 REQUEST: ${options.method} ${options.path}');
    debugPrint('Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('Body: ${options.data}');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint(
      '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
    );
    debugPrint('Data: ${response.data}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint(
      '❌ ERROR: ${err.requestOptions.method} ${err.requestOptions.path}',
    );
    debugPrint('Error Type: ${err.type}');
    debugPrint('Status Code: ${err.response?.statusCode}');
    debugPrint('Error Message: ${err.message}');
    if (err.response?.data != null) {
      debugPrint('Error Data: ${err.response?.data}');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    handler.next(err);
  }
}
