import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/presentation/screens/chatbot_screen.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// AI coach as an iOS-style bottom sheet (wallet FAB entry point).
abstract final class AiChatSheet {
  AiChatSheet._();

  static Future<void> show(BuildContext context) {
    HapticService.medium();
    final height = MediaQuery.sizeOf(context).height * 0.88;

    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.s1Dark
          : AppColors.s1Light,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => SizedBox(
        height: height,
        child: const ChatbotScreen(embedded: true),
      ),
    );
  }
}
