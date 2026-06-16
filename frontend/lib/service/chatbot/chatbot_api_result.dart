/// Result of calling the remote AI coach API.
class ChatbotApiResult {
  final bool isSuccess;
  final String? message;
  final bool quotaExceeded;
  final bool useLocalFallback;

  const ChatbotApiResult._({
    required this.isSuccess,
    this.message,
    this.quotaExceeded = false,
    this.useLocalFallback = false,
  });

  factory ChatbotApiResult.success(String message) {
    return ChatbotApiResult._(isSuccess: true, message: message);
  }

  factory ChatbotApiResult.quotaExceeded() {
    return const ChatbotApiResult._(
      isSuccess: false,
      quotaExceeded: true,
      useLocalFallback: true,
    );
  }

  factory ChatbotApiResult.fallback() {
    return const ChatbotApiResult._(
      isSuccess: false,
      useLocalFallback: true,
    );
  }

  factory ChatbotApiResult.failure(String message) {
    return ChatbotApiResult._(
      isSuccess: false,
      message: message,
      useLocalFallback: false,
    );
  }
}
