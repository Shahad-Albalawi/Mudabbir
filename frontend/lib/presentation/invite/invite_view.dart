import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/modern_gradient_appbar.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:share_plus/share_plus.dart';

class InviteView extends StatelessWidget {
  const InviteView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: ModernGradientAppBar(
        title: Text(ServerChallengeStrings.inviteAppBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppLayout.pageGutter),
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
            SizedBox(
              width: double.infinity,
              height: AppLayout.listRowHeight + 4,
              child: FilledButton.icon(
                onPressed: () => _shareInviteLink(context),
                icon: const Icon(CupertinoIcons.share, size: 18),
                label: Text(ServerChallengeStrings.inviteShareButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareInviteLink(BuildContext context) {
    const String inviteLink = 'https://yourapp.com/invite?ref=user123';
    Share.share(
      ServerChallengeStrings.inviteShareMessage(inviteLink),
      subject: ServerChallengeStrings.inviteShareSubject,
    );
  }
}
