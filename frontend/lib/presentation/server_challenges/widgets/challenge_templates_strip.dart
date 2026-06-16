import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/resources/styles_manager.dart';
import 'package:mudabbir/presentation/server_challenges/models/challenge_model.dart';
import 'package:mudabbir/presentation/server_challenges/providers/challenge_provider.dart';

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
    final templatesAsync = ref.watch(challengeTemplatesProvider);

    return templatesAsync.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
                    style: getBoldStyle(
                      fontSize: FontSize.s16,
                      color: ColorManager.darkGrey,
                    ),
                  ),
                  Text(
                    ServerChallengeStrings.templatesSubtitle,
                    style: getRegularStyle(
                      fontSize: FontSize.s12,
                      color: ColorManager.grey1,
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
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorManager.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ColorManager.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  template.localizedName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: getSemiBoldStyle(
                    fontSize: FontSize.s12,
                    color: ColorManager.darkGrey,
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
              style: getRegularStyle(
                fontSize: FontSize.s12,
                color: ColorManager.grey1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                ServerChallengeStrings.templateDays(template.durationDays),
                style: getRegularStyle(
                  fontSize: FontSize.s12,
                  color: ColorManager.primary,
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
    );
  }
}
