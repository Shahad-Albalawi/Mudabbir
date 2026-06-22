import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/app_animated_list_item.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:share_plus/share_plus.dart';

class InviteView extends StatefulWidget {
  const InviteView({super.key});

  @override
  State<InviteView> createState() => _InviteViewState();
}

class _InviteViewState extends State<InviteView> {
  bool _sharing = false;

  String _inviteLink() {
    final raw = getIt<HiveService>().getValue(HiveConstants.savedUserInfo);
    final refCode = raw is Map ? raw['id']?.toString() : null;
    if (refCode == null || refCode.isEmpty) {
      return 'https://mudabbir.app/invite';
    }
    return 'https://mudabbir.app/invite?ref=${Uri.encodeComponent(refCode)}';
  }

  Future<void> _shareInviteLink() async {
    HapticService.medium();
    setState(() => _sharing = true);
    try {
      final link = _inviteLink();
      await Share.share(
        ServerChallengeStrings.inviteShareMessage(link),
        subject: ServerChallengeStrings.inviteShareSubject,
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppGroupedScaffold(
      largeTitle: true,
      titleText: ServerChallengeStrings.inviteAppBarTitle,
      body: Padding(
        padding: const EdgeInsets.all(AppLayout.pageGutter),
        child: AppFadeIn(
          child: Column(
            children: [
              AppCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.person_2,
                      size: 40,
                      color: scheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ServerChallengeStrings.inviteFriendsTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ServerChallengeStrings.inviteFriendsSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.textMuted,
                            height: 1.4,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                button: true,
                label: ServerChallengeStrings.inviteShareButton,
                child: AppLoadingButton(
                  isLoading: _sharing,
                  label: ServerChallengeStrings.inviteShareButton,
                  onPressed: _shareInviteLink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
