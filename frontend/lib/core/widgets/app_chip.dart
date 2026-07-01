import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/core/utils/haptics.dart';

/// Pill filter / tag chip.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = selected
        ? colors.primary.withValues(alpha: 0.12)
        : colors.surfaceContainerHighest;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppTheme.radiusChip),
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                AppHaptics.selection();
                onTap!();
              },
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
