import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'failure.dart';

enum HttpMethod { GET, POST }

Future<Either<Failure, T>> requestData<T>({
  required String url,
  required T Function(dynamic json) parser,
  HttpMethod method = HttpMethod.GET,
  Map<String, String>? headers,
  Map<String, dynamic>? body, // used for POST
  Duration timeout = const Duration(seconds: 10),
}) async {
  try {
    http.Response response;

    if (method == HttpMethod.GET) {
      response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(timeout);
    } else if (method == HttpMethod.POST) {
      response = await http
          .post(
            Uri.parse(url),
            headers: headers ?? {'Content-Type': 'application/json'},
            body: jsonEncode(body ?? {}),
          )
          .timeout(timeout);
    } else {
      return Left(UnknownFailure('Unsupported HTTP method'));
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return Right(parser(data));
    } else {
      final msg = _messageFromErrorResponse(
        body: response.body,
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
      return Left(ServerFailure(response.statusCode, msg));
    }
  } on TimeoutException catch (e) {
    return Left(TimeoutFailure('Request timed out: ${e.message}'));
  } on http.ClientException catch (e) {
    return Left(NetworkFailure('Network error: ${e.message}'));
  } on FormatException catch (e) {
    return Left(ParsingFailure('Parsing error: ${e.message}'));
  } catch (e) {
    return Left(UnknownFailure('Unexpected error: $e'));
  }
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
    final decoded = jsonDecode(trimmed);
    if (decoded is Map<String, dynamic>) {
      final errors = decoded['errors'];
      if (errors is Map) {
        final first = _firstValidationError(errors);
        if (first != null && first.isNotEmpty) return first;
      }
      final msg = decoded['message'];
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
