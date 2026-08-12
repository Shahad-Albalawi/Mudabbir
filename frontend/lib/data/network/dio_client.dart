import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mudabbir/constants/api_constants.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';
import 'package:mudabbir/utils/dev_log.dart';

typedef UnauthorizedCallback = Future<void> Function();

/// Single shared HTTP client for all Laravel API calls.
class DioClient {
  DioClient({
    required AuthTokenSecureStore secureStore,
    UnauthorizedCallback? onUnauthorized,
  })  : _secureStore = secureStore,
        _onUnauthorized = onUnauthorized {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'MudabbirFlutter/1.0',
        },
      ),
    );

    _dio.interceptors.add(
      _AuthInterceptor(
        secureStore: _secureStore,
        onUnauthorized: _onUnauthorized,
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(_LoggingInterceptor());
    }
  }

  static String get baseUrl => ApiConstants.apiV1Base;

  static const Duration connectTimeout = ApiConstants.defaultTimeout;
  static const Duration receiveTimeout = ApiConstants.defaultTimeout;

  late final Dio _dio;
  final AuthTokenSecureStore _secureStore;
  final UnauthorizedCallback? _onUnauthorized;

  Dio get dio => _dio;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({
    required this.secureStore,
    this.onUnauthorized,
  });

  final AuthTokenSecureStore secureStore;
  final UnauthorizedCallback? onUnauthorized;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStore.readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      final authHeader = err.requestOptions.headers['Authorization'];
      final hadSession = authHeader is String && authHeader.isNotEmpty;
      if (hadSession && onUnauthorized != null) {
        unawaited(onUnauthorized!());
      }
    }

    handler.next(err);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    devLog('REQUEST: ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    devLog('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    devLog(
      'API ERROR: ${err.requestOptions.method} ${err.requestOptions.path} '
      '(${err.response?.statusCode ?? err.type})',
    );
    handler.next(err);
  }
}
