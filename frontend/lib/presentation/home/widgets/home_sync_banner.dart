import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_icons.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/pending_sync_status.dart';

/// Compact banner on Home when offline changes are queued for sync.
class HomeSyncBanner extends StatelessWidget {
  const HomeSyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final count = pendingSyncOperationCount();
    if (count <= 0) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.pageGutter,
        0,
        AppLayout.pageGutter,
        AppLayout.sectionGap,
      ),
      child: Material(
        color: scheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.smd,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(AppIcons.sync, size: 18, color: scheme.warning),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppStrings.homePendingSyncBanner(count),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
