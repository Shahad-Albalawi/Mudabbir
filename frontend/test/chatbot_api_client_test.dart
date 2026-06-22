import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/service/chatbot/chatbot_api_client.dart';

void main() {
  group('ChatbotApiClient', () {
    test('parseApiResponse reads nested message fields', () {
      final body = utf8.encode(
        '{"data":{"message":"مرحباً من الخادم"}}',
      );
      expect(
        ChatbotApiClient.parseApiResponse(body),
        'مرحباً من الخادم',
      );
    });

    test('parseApiResponse falls back to top-level message', () {
      final body = utf8.encode('{"message":"ok"}');
      expect(ChatbotApiClient.parseApiResponse(body), 'ok');
    });

    test('isQuotaMessage detects quota errors', () {
      expect(ChatbotApiClient.isQuotaMessage('QUOTA_EXCEEDED'), isTrue);
      expect(ChatbotApiClient.isQuotaMessage('rate limit hit'), isTrue);
      expect(ChatbotApiClient.isQuotaMessage('all good'), isFalse);
    });

    test('extractServerErrorMessage reads error map', () {
      final body = utf8.encode(
        '{"error":{"code":"QUOTA_EXCEEDED","message":"limit"}}',
      );
      expect(ChatbotApiClient.extractServerErrorMessage(body), 'limit');
    });

    test('candidatePayloads includes common keys', () {
      final payloads = ChatbotApiClient.candidatePayloads('hello');
      expect(payloads.map((p) => p.keys.single), containsAll(['content', 'prompt', 'message', 'input']));
    });
  });
}
