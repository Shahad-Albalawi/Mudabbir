import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mudabbir/data/local/chat_message_store.dart';
import 'package:mudabbir/data/network/failure.dart';
import 'package:mudabbir/domain/models/user/user_model.dart';
import 'package:mudabbir/domain/repository/user_repository/user_repository.dart';
import 'package:mudabbir/service/chatbot/chat_context_summary.dart';
import 'package:mudabbir/service/chatbot/chat_sse_service.dart';
import 'package:mudabbir/service/chatbot/chatbot_models.dart';

class MockUserRepository extends Mock implements UserRepository {}

/// Configurable auth repository for integration tests.
class FakeUserRepository extends Fake implements UserRepository {
  Future<Either<Failure, UserModel>> Function(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  )? registerHandler;

  Future<Either<Failure, UserModel>> Function(
    String email,
    String password,
  )? loginHandler;

  @override
  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) {
    return registerHandler!(
      name,
      email,
      password,
      passwordConfirmation,
    );
  }

  @override
  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) {
    return loginHandler!(email, password);
  }
}

/// In-memory chat store for widget tests (avoids SQLite + mockito [any]).
class FakeChatMessageStore extends Fake implements ChatMessageStore {
  final List<ChatMessage> appended = [];

  @override
  Future<List<ChatMessage>> loadRecent() async => const [];

  @override
  Future<void> append(ChatMessage message) async {
    appended.add(message);
  }

  @override
  Future<void> clear() async {
    appended.clear();
  }

  @override
  Future<void> updateLastAssistant(String text) async {}
}

/// Configurable SSE stub for chat widget tests.
class FakeChatSseService extends Fake implements ChatSseService {
  Stream<String> Function(String message)? onStream;

  @override
  Stream<String> streamReply({
    required String message,
    String? contextSummary,
  }) {
    return onStream?.call(message) ?? Stream.value('رد المساعد');
  }

  @override
  Future<String> fetchReply({
    required String message,
    String? contextSummary,
  }) async {
    return 'رد المساعد';
  }
}

class FakeChatContextSummary extends Fake implements ChatContextSummary {
  @override
  Future<String> build() async => 'summary';
}
