import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mudabbir/data/network/dio_client.dart';
import 'package:mudabbir/service/getit_init.dart';

/// SSE client for `POST /api/ai/chat` (OpenAI streaming).
class ChatSseService {
  ChatSseService({Dio? dio}) : _dio = dio ?? getIt<DioClient>().dio;

  final Dio _dio;

  Stream<String> streamReply({
    required String message,
    String? contextSummary,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      '/ai/chat',
      data: {
        'message': message,
        'stream': true,
        if (contextSummary != null && contextSummary.isNotEmpty)
          'context_summary': contextSummary,
      },
      options: Options(
        responseType: ResponseType.stream,
        headers: const {'Accept': 'text/event-stream'},
        receiveTimeout: const Duration(seconds: 90),
      ),
    );

    final body = response.data;
    if (body == null) return;

    final stream = utf8.decoder.bind(body.stream);
    var pending = '';

    await for (final chunk in stream) {
      pending += chunk;
      final parts = pending.split('\n');
      pending = parts.removeLast();

      for (final line in parts) {
        final trimmed = line.trim();
        if (!trimmed.startsWith('data:')) continue;
        final payload = trimmed.substring(5).trim();
        if (payload == '[DONE]') return;

        try {
          final json = jsonDecode(payload);
          if (json is Map && json['token'] is String) {
            final token = json['token'] as String;
            if (token.isNotEmpty) yield token;
          } else if (json is Map && json['error'] != null) {
            throw Exception(json['error'].toString());
          }
        } catch (_) {
          // Ignore malformed SSE chunks.
        }
      }
    }
  }

  /// Non-streaming fallback when SSE is unavailable.
  Future<String> fetchReply({
    required String message,
    String? contextSummary,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/ai/chat',
      data: {
        'message': message,
        'stream': false,
        if (contextSummary != null && contextSummary.isNotEmpty)
          'context_summary': contextSummary,
      },
    );

    final data = response.data;
    if (data == null) {
      throw Exception('Empty AI response');
    }

    final nested = data['data'];
    if (nested is Map && nested['message'] is String) {
      return nested['message'] as String;
    }
    if (data['message'] is String) {
      return data['message'] as String;
    }
    throw Exception('Unexpected AI response shape');
  }
}
