import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';

/// Info row — leading icon, label, trailing bold value.
class GoalDetailInfoRow extends StatelessWidget {
  const GoalDetailInfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? AppColors.t2Dark : AppColors.t2Light;
    final primary = isDark ? AppColors.t1Dark : AppColors.t1Light;

    return Row(
      children: [
        Icon(icon, size: 20, color: muted),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium(muted),
          ),
        ),
        valueWidget ??
            Text(
              value ?? '',
              style: AppTypography.bodyMedium(primary).copyWith(
                fontWeight: AppFontWeights.bold,
              ),
            ),
      ],
    );
  }
}
