enum ChatQuickAction { createGoal, adjustBudget, reduceCategory, exportReport }

enum PendingCommandType { createGoal, createBudget }

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class ExecutedCommand {
  final String table;
  final int rowId;
  final String summary;

  ExecutedCommand({
    required this.table,
    required this.rowId,
    required this.summary,
  });
}

const unsetChatbotUndo = Object();

class ChatbotState {
  final bool isLoading;
  final List<ChatMessage> messages;
  final bool isLoadingResponse;
  final ExecutedCommand? lastExecutedCommand;

  const ChatbotState({
    this.isLoading = false,
    this.messages = const [],
    this.isLoadingResponse = false,
    this.lastExecutedCommand,
  });

  ChatbotState copyWith({
    bool? isLoading,
    List<ChatMessage>? messages,
    bool? isLoadingResponse,
    Object? lastExecutedCommand = unsetChatbotUndo,
    bool clearLastExecutedCommand = false,
  }) {
    return ChatbotState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      isLoadingResponse: isLoadingResponse ?? this.isLoadingResponse,
      lastExecutedCommand: clearLastExecutedCommand
          ? null
          : identical(lastExecutedCommand, unsetChatbotUndo)
              ? this.lastExecutedCommand
              : lastExecutedCommand as ExecutedCommand?,
    );
  }
}
