import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir/presentation/chatbot/chat_notifier.dart';
import 'package:mudabbir/presentation/chatbot/chatbot_copy_helpers.dart';
import 'package:mudabbir/presentation/screens/chatbot_screen.dart';

import '../helpers/test_mocks.dart';
import '../helpers/widget_test_helpers.dart';

ChatNotifier _buildChatNotifier({
  required FakeChatMessageStore store,
  required FakeChatSseService sse,
  required FakeChatContextSummary contextSummary,
}) {
  return ChatNotifier(
    store: store,
    sse: sse,
    contextSummary: contextSummary,
  );
}

void main() {
  group('ChatbotScreen', () {
    late FakeChatMessageStore fakeStore;
    late FakeChatSseService fakeSse;
    late FakeChatContextSummary fakeContext;

    setUp(() {
      fakeStore = FakeChatMessageStore();
      fakeSse = FakeChatSseService();
      fakeContext = FakeChatContextSummary();
    });

    testWidgets('shows suggested questions when chat is empty', (tester) async {
      await tester.pumpWidget(
        wrapForWidgetTest(
          child: const ChatbotScreen(),
          overrides: [
            chatNotifierProvider.overrideWith((ref) {
              final notifier = _buildChatNotifier(
                store: fakeStore,
                sse: fakeSse,
                contextSummary: fakeContext,
              );
              ref.onDispose(() {
                notifier.messageController.dispose();
                notifier.scrollController.dispose();
              });
              return notifier;
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();
      clearBenignLayoutExceptions(tester);

      expect(find.text(ChatbotUi.suggestBalanceTitle), findsOneWidget);
      expect(find.text(ChatbotUi.suggestExpenseTitle), findsOneWidget);
      expect(find.text(ChatbotUi.suggestGoalsTitle), findsOneWidget);
      expect(find.text(ChatbotUi.suggestSavingsTitle), findsOneWidget);
    });

    testWidgets('sends a user message when tapping send', (tester) async {
      fakeSse.onStream = (_) async* {
        yield 'رد المساعد';
      };

      await tester.pumpWidget(
        wrapForWidgetTest(
          child: const ChatbotScreen(),
          overrides: [
            chatNotifierProvider.overrideWith((ref) {
              final notifier = _buildChatNotifier(
                store: fakeStore,
                sse: fakeSse,
                contextSummary: fakeContext,
              );
              ref.onDispose(() {
                notifier.messageController.dispose();
                notifier.scrollController.dispose();
              });
              return notifier;
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();
      clearBenignLayoutExceptions(tester);

      const userText = 'ما رصيدي؟';
      await tester.enterText(find.byType(TextField), userText);
      await tester.tap(find.byIcon(CupertinoIcons.arrow_up));
      await tester.pump();

      expect(find.text(userText), findsOneWidget);
      expect(
        fakeStore.appended.any((m) => m.isUser && m.text == userText),
        isTrue,
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ChatbotScreen)),
      );
      await container.read(chatNotifierProvider.notifier).clearMessages();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('shows typing indicator while assistant is streaming',
        (tester) async {
      final streamGate = Completer<void>();
      addTearDown(() {
        if (!streamGate.isCompleted) {
          streamGate.complete();
        }
      });

      fakeSse.onStream = (_) async* {
        await streamGate.future;
        yield 'رد';
      };

      await tester.pumpWidget(
        wrapForWidgetTest(
          child: const ChatbotScreen(),
          overrides: [
            chatNotifierProvider.overrideWith((ref) {
              final notifier = _buildChatNotifier(
                store: fakeStore,
                sse: fakeSse,
                contextSummary: fakeContext,
              );
              ref.onDispose(() {
                notifier.messageController.dispose();
                notifier.scrollController.dispose();
              });
              return notifier;
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();
      clearBenignLayoutExceptions(tester);

      await tester.enterText(find.byType(TextField), 'حلل مصروفاتي');
      await tester.tap(find.byIcon(CupertinoIcons.arrow_up));
      await tester.pump();

      final element = tester.element(find.byType(ChatbotScreen));
      final container = ProviderScope.containerOf(element);
      final chatState = container.read(chatNotifierProvider);

      expect(chatState.isStreaming, isTrue);
      expect(chatState.messages.last.isUser, isFalse);
      expect(chatState.messages.last.text, isEmpty);

      streamGate.complete();
      await container.read(chatNotifierProvider.notifier).clearMessages();
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
