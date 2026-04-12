import 'package:flutter/material.dart';

import 'package:mudabbir/persentation/resources/color_manager.dart';
import 'package:mudabbir/persentation/resources/modern_gradient_appbar.dart';
import 'package:mudabbir/persentation/resources/server_challenge_strings.dart';
import 'package:share_plus/share_plus.dart';

class InviteView extends StatelessWidget {
  const InviteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      appBar: ModernGradientAppBar(
        showBackButton: false,
        title: Row(
          children: [
            const SizedBox(width: 10),
            Text(ServerChallengeStrings.inviteAppBarTitle),
          ],
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: ColorManager.primaryWithOpacity10,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.people_alt_outlined,
                      size: 30,
                      color: ColorManager.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ServerChallengeStrings.inviteFriendsTitle,
                    style: TextStyle(
                      color: ColorManager.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ServerChallengeStrings.inviteFriendsSubtitle,
                    style: TextStyle(
                      color: ColorManager.textSecondary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _shareInviteLink(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.primary,
                  foregroundColor: ColorManager.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      ServerChallengeStrings.inviteShareButton,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
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
