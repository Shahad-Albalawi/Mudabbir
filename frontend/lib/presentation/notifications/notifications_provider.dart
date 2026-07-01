import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/data/network/api_exception.dart';
import 'package:mudabbir/domain/models/app_notification.dart';
import 'package:mudabbir/presentation/resources/network_messages.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/data/remote/notification_api_service.dart';

class NotificationsState {
  const NotificationsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  final List<AppNotification> items;
  final bool isLoading;
  final String? error;

  int get unreadCount => items.where((n) => n.isUnread).length;

  NotificationsState copyWith({
    List<AppNotification>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier({bool loadOnInit = true}) : super(const NotificationsState()) {
    if (loadOnInit) load();
  }

  final _api = getIt<NotificationApiService>();

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _api.fetchNotifications();
      state = state.copyWith(items: items, isLoading: false, clearError: true);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.userMessage,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkUserMessages.unknown,
      );
    }
  }

  Future<void> markRead(int id) async {
    await _api.markRead(id);
    state = state.copyWith(
      items: [
        for (final n in state.items)
          if (n.id == id)
            AppNotification(
              id: n.id,
              type: n.type,
              title: n.title,
              body: n.body,
              readAt: DateTime.now(),
              createdAt: n.createdAt,
            )
          else
            n,
      ],
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>(
  (_) => NotificationsNotifier(),
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});
