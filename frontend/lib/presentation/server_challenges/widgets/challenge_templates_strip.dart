import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/service/haptic_service.dart';

class ChallengeTemplatesStrip extends ConsumerWidget {
  const ChallengeTemplatesStrip({super.key});

  IconData _iconFor(String icon) {
    switch (icon) {
      case 'week':
        return Icons.date_range_rounded;
      case 'savings':
        return Icons.savings_outlined;
      case 'coffee':
        return Icons.local_cafe_outlined;
      case 'moon':
        return Icons.nightlight_round;
      default:
        return Icons.flag_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final templatesAsync = ref.watch(challengeTemplatesProvider);

    return templatesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            AppSkeletonBox(height: 132, width: 220),
            SizedBox(width: 12),
            AppSkeletonBox(height: 132, width: 220),
          ],
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (templates) {
        if (templates.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ServerChallengeStrings.templatesTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    ServerChallengeStrings.templatesSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 132,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: templates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return _TemplateCard(
                    template: template,
                    icon: _iconFor(template.icon),
                    onStart: () => _startTemplate(ref, template.id),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
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

class _TemplateCard extends StatelessWidget {
  final ChallengeTemplateModel template;
  final IconData icon;
  final VoidCallback onStart;

  const _TemplateCard({
    required this.template,
    required this.icon,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 220,
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
            children: [
              Icon(icon, color: scheme.chromeIcon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  template.localizedName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              template.localizedDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.textMuted,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                ServerChallengeStrings.templateDays(template.durationDays),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onStart,
                child: Text(ServerChallengeStrings.useTemplate),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }
}
