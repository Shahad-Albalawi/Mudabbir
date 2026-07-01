import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';

/// Profile header — avatar, name, email, edit chevron.
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({
    super.key,
    required this.displayName,
    required this.email,
    required this.onEdit,
  });

  final String displayName;
  final String email;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final name = displayName.isEmpty ? AppStrings.title : displayName;
    final initial =
        name.isNotEmpty ? name.characters.first.toUpperCase() : '?';

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onEdit,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colors.primary,
            child: Text(
              initial,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.textInverse,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_left_rounded,
            color: colors.textTertiary,
            size: 24,
          ),
        ],
      ),
    );
  }
}
