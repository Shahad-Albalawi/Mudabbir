import 'package:mudabbir/data/local/database_helper.dart';
import 'package:mudabbir/service/chatbot/chatbot_models.dart';
import 'package:mudabbir/service/getit_init.dart';

/// Persists the last 50 chat messages in SQLite.
class ChatMessageStore {
  ChatMessageStore({DbHelper? db}) : _db = db ?? getIt<DbHelper>();

  final DbHelper _db;
  static const _maxMessages = 50;

  Future<List<ChatMessage>> loadRecent() async {
    final result = await _db.complexQuery(
      table: 'chat_messages',
      columns: ['text', 'is_user', 'created_at'],
      orderBy: 'id ASC',
      limit: _maxMessages,
    );

    return result.fold((_) => <ChatMessage>[], (rows) {
      return rows
          .map(
            (row) => ChatMessage(
              text: row['text'] as String,
              isUser: (row['is_user'] as int) == 1,
              timestamp: DateTime.tryParse(row['created_at'] as String? ?? '') ??
                  DateTime.now(),
            ),
          )
          .toList();
    });
  }

  Future<void> append(ChatMessage message) async {
    await _db.insert('chat_messages', {
      'text': message.text,
      'is_user': message.isUser ? 1 : 0,
      'created_at': message.timestamp.toIso8601String(),
    });
    await _trim();
  }

  Future<void> updateLastAssistant(String text) async {
    final result = await _db.complexQuery(
      table: 'chat_messages',
      columns: ['id'],
      where: 'is_user = 0',
      orderBy: 'id DESC',
      limit: 1,
    );

    await result.fold((_) async {}, (rows) async {
      if (rows.isEmpty) return;
      await _db.update(
        'chat_messages',
        {'text': text},
        'id = ?',
        [rows.first['id']],
      );
    });
  }

  Future<void> clear() async {
    await _db.delete('chat_messages', '1 = ?', [1]);
  }

  Future<void> _trim() async {
    final countResult = await _db.complexQuery(
      table: 'chat_messages',
      columns: ['COUNT(*) as total'],
    );

    await countResult.fold((_) async {}, (rows) async {
      final total = (rows.first['total'] as num?)?.toInt() ?? 0;
      if (total <= _maxMessages) return;

      final excess = total - _maxMessages;
      final oldest = await _db.complexQuery(
        table: 'chat_messages',
        columns: ['id'],
        orderBy: 'id ASC',
        limit: excess,
      );

      await oldest.fold((_) async {}, (rows) async {
        for (final row in rows) {
          await _db.delete('chat_messages', 'id = ?', [row['id']]);
        }
      });
    });
  }
}
