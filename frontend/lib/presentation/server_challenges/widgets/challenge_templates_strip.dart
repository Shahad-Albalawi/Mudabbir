import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/presentation/server_challenges/challenge_copy_helpers.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/widgets/section_title_text.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// Preset quick-start templates — compact navy cards in a horizontal strip.
class _QuickPreset {
  const _QuickPreset({
    required this.templateId,
    required this.icon,
    required this.labelAr,
    required this.labelEn,
  });

  final String templateId;
  final IconData icon;
  final String labelAr;
  final String labelEn;

  String get label =>
      ServerChallengeStrings.isArabic ? labelAr : labelEn;
}

const _presets = [
  _QuickPreset(
    templateId: 'save_500_month',
    icon: Icons.savings_outlined,
    labelAr: 'ادخار أسبوع',
    labelEn: 'Weekly save',
  ),
  _QuickPreset(
    templateId: 'no_extra_week',
    icon: Icons.money_off_csred_outlined,
    labelAr: 'بدون مصروف',
    labelEn: 'No spend',
  ),
  _QuickPreset(
    templateId: 'save_500_month',
    icon: Icons.groups_outlined,
    labelAr: 'هدف مشترك',
    labelEn: 'Shared goal',
  ),
];

class ChallengeTemplatesStrip extends ConsumerWidget {
  const ChallengeTemplatesStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: SectionTitleText(
            ServerChallengeStrings.quickTemplatesTitle,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 92,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _presets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final preset = _presets[index];
              return _QuickTemplateCard(
                icon: preset.icon,
                label: preset.label,
                onTap: () => _startTemplate(ref, preset.templateId),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Future<void> _startTemplate(WidgetRef ref, String templateId) async {
    HapticService.medium();
    await ref
        .read(challengeOperationProvider.notifier)
        .createFromTemplate(templateId);
    await ref.read(challengesProvider.notifier).refreshChallenges();
  }
}

class _QuickTemplateCard extends StatelessWidget {
  const _QuickTemplateCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? context.colors.primary : AppColors.navy1;

    return SizedBox(
      width: 108,
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.gold, size: 26),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textInverse,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
