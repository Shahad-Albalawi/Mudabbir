import 'dart:async';
import 'dart:convert';

import 'package:mudabbir/constants/api_constants.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/data/network/dio_client.dart';
import 'package:mudabbir/service/getit_init.dart';

enum HttpMethod { GET, POST }

Future<Either<Failure, T>> requestData<T>({
  required String url,
  required T Function(dynamic json) parser,
  HttpMethod method = HttpMethod.GET,
  Map<String, String>? headers,
  Map<String, dynamic>? body,
  Duration timeout = ApiConstants.defaultTimeout,
}) async {
  final dio = getIt<DioClient>().dio;

  try {
    final Response<dynamic> response;
    final options = Options(
      headers: headers,
      receiveTimeout: timeout,
      sendTimeout: timeout,
    );

    if (method == HttpMethod.GET) {
      response = await dio.get(url, options: options);
    } else if (method == HttpMethod.POST) {
      response = await dio.post(
        url,
        data: body ?? {},
        options: options.copyWith(
          contentType: Headers.jsonContentType,
          headers: {
            ...?headers,
            'Content-Type': 'application/json',
          },
        ),
      );
    } else {
      return Left(UnknownFailure('Unsupported HTTP method'));
    }

    final statusCode = response.statusCode ?? 0;
    if (statusCode >= 200 && statusCode < 300) {
      return Right(parser(response.data));
    }

    final bodyText = _responseBodyAsString(response.data);
    final fieldErrors = _fieldErrorsFromBody(bodyText);
    if (statusCode == 422 && fieldErrors != null && fieldErrors.isNotEmpty) {
      return Left(ValidationFieldsFailure(fieldErrors));
    }
    final msg = _messageFromErrorResponse(
      body: bodyText,
      statusCode: statusCode,
      reasonPhrase: response.statusMessage,
    );
    return Left(ServerFailure(statusCode, msg));
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Left(TimeoutFailure('Request timed out: ${e.message}'));
    }
    if (e.type == DioExceptionType.connectionError) {
      return Left(NetworkFailure('Network error: ${e.message}'));
    }
    final statusCode = e.response?.statusCode ?? 0;
    if (statusCode > 0) {
      final bodyText = _responseBodyAsString(e.response?.data);
      final fieldErrors = _fieldErrorsFromBody(bodyText);
      if (statusCode == 422 && fieldErrors != null && fieldErrors.isNotEmpty) {
        return Left(ValidationFieldsFailure(fieldErrors));
      }
      final msg = _messageFromErrorResponse(
        body: bodyText,
        statusCode: statusCode,
        reasonPhrase: e.response?.statusMessage,
      );
      return Left(ServerFailure(statusCode, msg));
    }
    return Left(NetworkFailure('Network error: ${e.message}'));
  } on FormatException catch (e) {
    return Left(ParsingFailure('Parsing error: ${e.message}'));
  } catch (e) {
    return Left(UnknownFailure('Unexpected error: $e'));
  }
}

String _responseBodyAsString(dynamic data) {
  if (data == null) return '';
  if (data is String) return data;
  if (data is Map || data is List) {
    return jsonEncode(data);
  }
  return data.toString();
}

/// Pulls Laravel-style JSON (`message`, `errors`) so the UI is not stuck on
/// `reasonPhrase` / English client labels like "Network error".
String _messageFromErrorResponse({
  required String body,
  required int statusCode,
  required String? reasonPhrase,
}) {
  final trimmed = body.trim();
  if (trimmed.isEmpty) {
    return _fallbackMessageForStatus(statusCode);
  }

  try {
    final parsed = jsonDecode(trimmed);
    if (parsed is Map<String, dynamic>) {
      final errors = parsed['errors'];
      if (errors is Map) {
        final first = _firstValidationError(errors);
        if (first != null && first.isNotEmpty) return first;
      }
      final msg = parsed['message'];
      if (msg is String && msg.trim().isNotEmpty) return msg.trim();
    }
  } catch (_) {}

  final phrase = reasonPhrase?.trim();
  if (phrase != null &&
      phrase.isNotEmpty &&
      phrase != '<none>' &&
      phrase.toLowerCase() != 'internal server error') {
    return phrase;
  }
  return _fallbackMessageForStatus(statusCode);
}

String? _firstValidationError(Map<dynamic, dynamic> errors) {
  for (final entry in errors.entries) {
    final v = entry.value;
    if (v is List && v.isNotEmpty) {
      final first = v.first;
      if (first is String && first.trim().isNotEmpty) return first.trim();
    }
  }
  return null;
}

Map<String, String>? _fieldErrorsFromBody(String body) {
  final trimmed = body.trim();
  if (trimmed.isEmpty) return null;
  try {
    final parsed = jsonDecode(trimmed);
    if (parsed is! Map<String, dynamic>) return null;
    final errors = parsed['errors'];
    if (errors is! Map) return null;
    final result = <String, String>{};
    for (final entry in errors.entries) {
      final v = entry.value;
      if (v is List && v.isNotEmpty) {
        final first = v.first;
        if (first is String && first.trim().isNotEmpty) {
          result[entry.key.toString()] = first.trim();
        }
      }
    }
    return result.isEmpty ? null : result;
  } catch (_) {
    return null;
  }
}

String _fallbackMessageForStatus(int code) {
  if (code == 401) {
    return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
  }
  if (code == 403) {
    return 'غير مسموح بتنفيذ هذا الإجراء.';
  }
  if (code == 404) {
    return 'خدمة غير متوفرة حالياً. تحقق من الاتصال أو إعدادات الخادم.';
  }
  if (code == 422) {
    return 'البيانات المدخلة غير صالحة. راجع الحقول وحاول مرة أخرى.';
  }
  if (code == 429) {
    return 'طلبات كثيرة. انتظر قليلاً ثم أعد المحاولة.';
  }
  if (code >= 500) {
    return 'الخادم يواجه مشكلة مؤقتة. حاول لاحقاً.';
  }
  return 'تعذر إكمال الطلب ($code). حاول مرة أخرى.';
}
