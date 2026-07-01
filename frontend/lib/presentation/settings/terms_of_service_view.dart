import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/widgets/section_title_text.dart';

/// In-app terms of service.
class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppGroupedScaffold(
      titleText: AppStrings.settingsTermsTitle,
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
            AppStrings.settingsTermsIntro,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppLayout.sectionGap),
          _Section(
            title: AppStrings.settingsTermsUseTitle,
            body: AppStrings.settingsTermsUseBody,
          ),
          _Section(
            title: AppStrings.settingsTermsDataTitle,
            body: AppStrings.settingsTermsDataBody,
          ),
          _Section(
            title: AppStrings.settingsTermsChangesTitle,
            body: AppStrings.settingsTermsChangesBody,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitleText(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
