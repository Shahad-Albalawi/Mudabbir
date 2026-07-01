import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/core/theme/theme_provider.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// Dark-mode switch with miniature light/dark previews — applies theme instantly.
class DarkModeToggle extends ConsumerWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Semantics(
      toggled: isDark,
      label: AppStrings.themeDark,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: scheme.chromeIcon,
        ),
        title: Text(AppStrings.themeDark),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              _ThemeMiniPreview(
                isDark: false,
                selected: !isDark,
                label: AppStrings.themeLight,
              ),
              const SizedBox(width: 10),
              _ThemeMiniPreview(
                isDark: true,
                selected: isDark,
                label: AppStrings.themeDark,
              ),
            ],
          ),
        ),
        trailing: Switch.adaptive(
          value: isDark,
          activeThumbColor: AppColors.navy4,
          onChanged: (_) {
            HapticService.light();
            ref.read(themeProvider.notifier).toggle();
          },
        ),
        onTap: () {
          HapticService.light();
          ref.read(themeProvider.notifier).toggle();
        },
      ),
    );
  }
}

class _ThemeMiniPreview extends StatelessWidget {
  const _ThemeMiniPreview({
    required this.isDark,
    required this.selected,
    required this.label,
  });

  final bool isDark;
  final bool selected;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.s1Dark : AppColors.s1Light;
    final accent = isDark ? AppColors.navy4 : AppColors.navy1;
    final border = selected ? accent : AppColors.bdLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 52,
          height: 36,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: border,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: isDark ? AppColors.bdDark : AppColors.bdLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? accent
                    : Theme.of(context).colorScheme.textMuted,
              ),
        ),
      ],
    );
  }
}
