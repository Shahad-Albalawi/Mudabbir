import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mudabbir/presentation/chatbot/chatbot_copy_helpers.dart';
import 'package:mudabbir/service/chatbot/chatbot_api_result.dart';
import 'package:mudabbir/utils/dev_log.dart';

/// HTTP client for chatbot LLM endpoints with retry across URL/payload variants.
class ChatbotApiClient {
  ChatbotApiClient({
    required Dio dio,
    required List<String> apiUrls,
    this.timeout = const Duration(seconds: 45),
  })  : _dio = dio,
        _apiUrls = apiUrls;

  final Dio _dio;
  final List<String> _apiUrls;
  final Duration timeout;

  Future<ChatbotApiResult> send(String content) async {
    Object? lastError;

    for (final url in _apiUrls) {
      devLog('[Chatbot API] Trying $url (timeout: ${timeout.inSeconds}s)');

      for (final body in candidatePayloads(content)) {
        try {
          final stopwatch = Stopwatch()..start();
          final response = await _dio.post<List<int>>(
            url,
            data: body,
            options: Options(
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'User-Agent': 'MudabbirFlutter/1.0',
              },
              receiveTimeout: timeout,
              sendTimeout: timeout,
              responseType: ResponseType.bytes,
            ),
          );

          stopwatch.stop();
          final statusCode = response.statusCode ?? 0;
          final bodyBytes = response.data ?? const <int>[];
          devLog(
            '[Chatbot API] $statusCode ${stopwatch.elapsedMilliseconds}ms body=$body',
          );

          if (statusCode == 200) {
            final result = parseApiResponse(bodyBytes);
            if (result.isNotEmpty) {
              return ChatbotApiResult.success(result);
            }
            return ChatbotApiResult.fallback();
          }

          if (statusCode == 429 || isQuotaResponse(statusCode, bodyBytes)) {
            return ChatbotApiResult.quotaExceeded();
          }

          if (statusCode >= 500) {
            final serverMessage = extractServerErrorMessage(bodyBytes);
            if (isQuotaMessage(serverMessage)) {
              return ChatbotApiResult.quotaExceeded();
            }
            if (serverMessage.contains('53')) {
              return ChatbotApiResult.failure(ChatbotUi.server53);
            }
            lastError = 'HTTP $statusCode: $serverMessage';
            continue;
          }

          if (statusCode == 404 || statusCode == 405 || statusCode == 422) {
            lastError = 'HTTP $statusCode';
            continue;
          }

          return ChatbotApiResult.failure(ChatbotUi.httpError(statusCode));
        } on DioException catch (e) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            return ChatbotApiResult.fallback();
          }
          if (e.type == DioExceptionType.connectionError) {
            lastError = e;
            continue;
          }
          lastError = e;
          continue;
        } on SocketException catch (e) {
          lastError = e;
          continue;
        } catch (e) {
          lastError = e;
          continue;
        }
      }
    }

    devLog('[Chatbot API] All retries failed: $lastError');
    if (lastError is SocketException ||
        (lastError is DioException &&
            lastError.type == DioExceptionType.connectionError)) {
      return ChatbotApiResult.fallback();
    }
    return ChatbotApiResult.fallback();
  }

  static bool isQuotaResponse(int statusCode, List<int> bodyBytes) {
    if (statusCode == 429) return true;
    return isQuotaMessage(extractServerErrorMessage(bodyBytes));
  }

  static bool isQuotaMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('quota') ||
        lower.contains('rate limit') ||
        lower.contains('resource exhausted') ||
        lower.contains('quota_exceeded');
  }

  static String parseApiResponse(List<int> bodyBytes) {
    try {
      final body = utf8.decode(bodyBytes, allowMalformed: true);
      final json = jsonDecode(body) as Map<String, dynamic>;
      final message =
          json['message'] ??
          json['data']?['message'] ??
          json['text'] ??
          json['response'] ??
          json['content'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }
      if (json['data'] != null) {
        final data = json['data'];
        if (data is Map) {
          final msg = data['message'] ?? data['text'] ?? data['content'];
          if (msg != null) return msg.toString().trim();
        }
        if (data is String && data.trim().isNotEmpty) return data.trim();
      }
      return ChatbotUi.parseResponseFail;
    } catch (_) {
      return ChatbotUi.parseError;
    }
  }

  static List<Map<String, dynamic>> candidatePayloads(String content) {
    return [
      {'content': content},
      {'prompt': content},
      {'message': content},
      {'input': content},
    ];
  }

  static String extractServerErrorMessage(List<int> bodyBytes) {
    try {
      final body = utf8.decode(bodyBytes, allowMalformed: true);
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final errors = decoded['errors'];
        if (errors is Map<String, dynamic>) {
          final code = errors['code']?.toString() ?? '';
          final details = errors['details'];
          if (code == 'QUOTA_EXCEEDED') {
            final msg = decoded['message']?.toString() ?? '';
            return msg.isNotEmpty ? msg : 'QUOTA_EXCEEDED';
          }
          if (details is Map && details.isNotEmpty) {
            final first = details.values.first;
            if (first is List && first.isNotEmpty) {
              return first.first.toString();
            }
          }
        }

        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final code = error['code']?.toString() ?? '';
          final msg = error['message']?.toString() ?? '';
          if (code == 'QUOTA_EXCEEDED') {
            return msg.isNotEmpty ? msg : 'QUOTA_EXCEEDED';
          }
          if (msg.isNotEmpty) return msg;
        }
        final msg = decoded['message'] ?? decoded['error'] ?? decoded['detail'];
        if (msg != null) return msg.toString();
      }
      return body;
    } catch (_) {
      return 'Server error';
    }
  }
}
