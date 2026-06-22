import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_section_header.dart';

/// In-app privacy policy (required for Play Store Data safety).
class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppGroupedScaffold(
      titleText: AppStrings.privacyPolicyTitle,
      largeTitle: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.pageGutter,
          12,
          AppLayout.pageGutter,
          AppLayout.bottomNavClearance,
        ),
        children: [
          Text(
            AppStrings.privacyPolicyIntro,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppLayout.sectionGap),
          _Section(
            title: AppStrings.privacyPolicyDataWeCollectTitle,
            body: AppStrings.privacyPolicyDataWeCollectBody,
          ),
          _Section(
            title: AppStrings.privacyPolicyHowWeUseTitle,
            body: AppStrings.privacyPolicyHowWeUseBody,
          ),
          _Section(
            title: AppStrings.privacyPolicyThirdPartyTitle,
            body: AppStrings.privacyPolicyThirdPartyBody,
          ),
          _Section(
            title: AppStrings.privacyPolicySecurityTitle,
            body: AppStrings.privacyPolicySecurityBody,
          ),
          _Section(
            title: AppStrings.privacyPolicyContactTitle,
            body: AppStrings.privacyPolicyContactBody,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: title),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
