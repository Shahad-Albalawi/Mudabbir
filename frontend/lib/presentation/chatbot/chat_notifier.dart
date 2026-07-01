import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/local/chat_message_store.dart';
import 'package:mudabbir/service/chatbot/chat_context_summary.dart';
import 'package:mudabbir/service/chatbot/chat_sse_service.dart';
import 'package:mudabbir/presentation/chatbot/chatbot_copy_helpers.dart';
import 'package:mudabbir/service/chatbot/chatbot_models.dart';

class ChatScreenState {
  const ChatScreenState({
    this.isLoading = true,
    this.isStreaming = false,
    this.messages = const [],
    this.errorMessage,
    this.showSuggestions = true,
    this.suggestions = const [],
  });

  final bool isLoading;
  final bool isStreaming;
  final List<ChatMessage> messages;
  final String? errorMessage;
  final bool showSuggestions;
  final List<String> suggestions;

  static ChatScreenState initial() => ChatScreenState(
        suggestions: List<String>.from(ChatbotUi.defaultSuggestions),
      );

  ChatScreenState copyWith({
    bool? isLoading,
    bool? isStreaming,
    List<ChatMessage>? messages,
    String? errorMessage,
    bool clearError = false,
    bool? showSuggestions,
    List<String>? suggestions,
  }) {
    return ChatScreenState(
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      messages: messages ?? this.messages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      showSuggestions: showSuggestions ?? this.showSuggestions,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}

final chatNotifierProvider =
    StateNotifierProvider.autoDispose<ChatNotifier, ChatScreenState>((ref) {
  final notifier = ChatNotifier();
  ref.onDispose(() {
    notifier.messageController.dispose();
    notifier.scrollController.dispose();
  });
  return notifier;
});

class ChatNotifier extends StateNotifier<ChatScreenState> {
  ChatNotifier({
    ChatMessageStore? store,
    ChatSseService? sse,
    ChatContextSummary? contextSummary,
  })  : _store = store ?? ChatMessageStore(),
        _sse = sse ?? ChatSseService(),
        _contextSummary = contextSummary ?? ChatContextSummary(),
        super(ChatScreenState.initial()) {
    _loadHistory();
  }

  static List<String> get defaultSuggestions => ChatbotUi.defaultSuggestions;

  final ChatMessageStore _store;
  final ChatSseService _sse;
  final ChatContextSummary _contextSummary;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final _random = Random();

  String _streamBuffer = '';
  String _streamDisplayed = '';
  bool _streamComplete = false;
  bool _revealActive = false;
  int _sendGeneration = 0;

  Future<void> _loadHistory() async {
    try {
      final messages = await _store.loadRecent();
      state = state.copyWith(
        isLoading: false,
        messages: messages,
        showSuggestions: messages.isEmpty,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void refreshSuggestions() {
    final pool = [...ChatbotUi.alternateSuggestions]..shuffle(_random);
    final picked = <String>[];
    for (final item in pool) {
      if (picked.length >= 3) break;
      if (!state.suggestions.contains(item)) {
        picked.add(item);
      }
    }
    while (picked.length < 3) {
      final fallback = ChatbotUi.alternateSuggestions[
          picked.length % ChatbotUi.alternateSuggestions.length];
      if (!picked.contains(fallback)) {
        picked.add(fallback);
      } else {
        break;
      }
    }
    state = state.copyWith(suggestions: picked);
  }

  Future<void> sendMessage([String? overrideText]) async {
    final text = (overrideText ?? messageController.text).trim();
    if (text.isEmpty || state.isStreaming) return;

    if (overrideText == null) {
      messageController.clear();
    }

    final userMessage = ChatMessage(text: text, isUser: true);
    final withUser = [...state.messages, userMessage];

    state = state.copyWith(
      messages: withUser,
      isStreaming: true,
      showSuggestions: false,
      clearError: true,
    );

    await _store.append(userMessage);

    final generation = ++_sendGeneration;
    _resetStreamState();
    _appendAssistantPlaceholder();

    try {
      final contextSummary = await _contextSummary.build();
      await _streamAssistantReply(text, contextSummary, generation);
    } catch (_) {
      await _fallbackReply(text, generation);
    } finally {
      if (generation == _sendGeneration) {
        state = state.copyWith(isStreaming: false);
        _scrollToBottomSoon();
      }
    }
  }

  void sendSuggestedMessage(String text) => sendMessage(text);

  Future<void> clearMessages() async {
    _sendGeneration++;
    _resetStreamState();
    messageController.clear();
    await _store.clear();
    state = const ChatScreenState(isLoading: false);
  }

  void _resetStreamState() {
    _streamBuffer = '';
    _streamDisplayed = '';
    _streamComplete = false;
    _revealActive = false;
  }

  void _appendAssistantPlaceholder() {
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(text: '', isUser: false),
      ],
    );
  }

  Future<void> _streamAssistantReply(
    String userText,
    String contextSummary,
    int generation,
  ) async {
    await for (final token in _sse.streamReply(
      message: userText,
      contextSummary: contextSummary,
    )) {
      if (generation != _sendGeneration) return;
      _streamBuffer += token;
      await _revealWords(generation);
    }

    if (generation != _sendGeneration) return;

    _streamComplete = true;
    await _revealWords(generation, flushAll: true);

    final finalText = _streamDisplayed.trim().isEmpty
        ? _streamBuffer.trim()
        : _streamDisplayed.trim();

    if (finalText.isEmpty) {
      throw Exception('Empty stream');
    }

    _updateLastAssistant(finalText);
    await _store.append(ChatMessage(text: finalText, isUser: false));
  }

  Future<void> _fallbackReply(String userText, int generation) async {
    if (generation != _sendGeneration) return;

    try {
      final contextSummary = await _contextSummary.build();
      final reply = await _sse.fetchReply(
        message: userText,
        contextSummary: contextSummary,
      );
      if (generation != _sendGeneration) return;

      _streamBuffer = reply;
      _streamComplete = true;
      await _revealWords(generation, flushAll: true);

      final finalText = _streamDisplayed.trim().isEmpty
          ? reply.trim()
          : _streamDisplayed.trim();

      _updateLastAssistant(finalText);
      await _store.append(ChatMessage(text: finalText, isUser: false));
    } catch (e) {
      if (generation != _sendGeneration) return;
      const errorText =
          'عذراً، تعذر الاتصال بالمساعد الذكي. تحقق من الاتصال وحاول مرة أخرى.';
      _updateLastAssistant(errorText);
      await _store.append(ChatMessage(text: errorText, isUser: false));
      state = state.copyWith(errorMessage: errorText);
    }
  }

  Future<void> _revealWords(int generation, {bool flushAll = false}) async {
    if (_revealActive) return;
    _revealActive = true;

    try {
      while (generation == _sendGeneration) {
        final remaining = _streamBuffer.substring(_streamDisplayed.length);
        if (remaining.isEmpty) {
          if (flushAll || _streamComplete) break;
          break;
        }

        final wordMatch = RegExp(r'^\S+\s*').firstMatch(remaining);
        if (wordMatch == null) {
          if (flushAll || _streamComplete) {
            _streamDisplayed = _streamBuffer;
            _updateLastAssistant(_streamDisplayed);
          }
          break;
        }

        final chunk = wordMatch.group(0)!;
        final hasMore = remaining.length > chunk.length;
        if (!hasMore && !_streamComplete && !flushAll) {
          break;
        }

        _streamDisplayed += chunk;
        _updateLastAssistant(_streamDisplayed);
        _scrollToBottomSoon();
        await Future<void>.delayed(const Duration(milliseconds: 30));
      }

      if ((flushAll || _streamComplete) &&
          generation == _sendGeneration &&
          _streamDisplayed.length < _streamBuffer.length) {
        _streamDisplayed = _streamBuffer;
        _updateLastAssistant(_streamDisplayed);
      }
    } finally {
      _revealActive = false;
      if (generation == _sendGeneration &&
          !_streamComplete &&
          _streamDisplayed.length < _streamBuffer.length) {
        unawaited(_revealWords(generation));
      }
    }
  }

  void _updateLastAssistant(String text) {
    final messages = [...state.messages];
    if (messages.isEmpty) return;

    final last = messages.last;
    if (!last.isUser) {
      messages[messages.length - 1] =
          ChatMessage(text: text, isUser: false, timestamp: last.timestamp);
      state = state.copyWith(messages: messages);
    }
  }

  void scrollToBottom() => _scrollToBottomSoon();

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      final target = scrollController.position.maxScrollExtent;
      if (target <= 0) return;
      scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }
}
