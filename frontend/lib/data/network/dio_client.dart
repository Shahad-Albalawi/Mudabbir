import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mudabbir/constants/api_constants.dart';
import 'package:mudabbir/utils/dev_log.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/service/security/auth_token_secure_store.dart';

class DioClient {
  static String get baseUrl => ApiConstants.apiV1Base;

  static const Duration connectTimeout = ApiConstants.defaultTimeout;
  static const Duration receiveTimeout = ApiConstants.defaultTimeout;

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

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    String? token = await getIt<AuthTokenSecureStore>().readToken();
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
      if (hadSession) {
        unawaited(getIt<AuthNotifier>().didLogout());
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
