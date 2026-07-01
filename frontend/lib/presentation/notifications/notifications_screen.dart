import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/notifications/notifications_provider.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsProvider);
    final colors = context.colors;

    return AppGroupedScaffold(
      titleText: AppStrings.notificationsTitle,
      largeTitle: true,
      showBackButton: true,
      body: state.isLoading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? IOSEmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: AppStrings.notificationsEmpty,
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(notificationsProvider.notifier).load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.pageGutter,
                      AppSpacing.md,
                      AppLayout.pageGutter,
                      AppLayout.bottomNavClearance,
                    ),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return Material(
                        color: item.isUnread
                            ? colors.primarySurface
                            : colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          title: Text(
                            item.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: item.isUnread
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(item.body),
                              if (item.createdAt != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  DateFormat.yMMMd(
                                    AppStrings.isEnglishLocale ? 'en' : 'ar',
                                  ).add_jm().format(item.createdAt!.toLocal()),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: colors.textTertiary),
                                ),
                              ],
                            ],
                          ),
                          onTap: item.isUnread
                              ? () => ref
                                  .read(notificationsProvider.notifier)
                                  .markRead(item.id)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
