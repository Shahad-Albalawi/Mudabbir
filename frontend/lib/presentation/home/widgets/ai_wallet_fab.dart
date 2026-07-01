import 'package:flutter/material.dart';
import 'package:mudabbir/core/theme/app_colors.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/haptic_service.dart';

/// زر مساعد ذكاء اصطناعي — Sparkles فقط مع نبضة خفيفة كل 3.2ث.
class AiWalletFab extends StatefulWidget {
  const AiWalletFab({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<AiWalletFab> createState() => _AiWalletFabState();
}

class _AiWalletFabState extends State<AiWalletFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.chatbotFabLabel,
      button: true,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final scale = 1.0 + (_pulse.value * 0.05);
          return Transform.scale(
            scale: scale,
            child: Material(
              color: AppColors.navy1,
              shape: const CircleBorder(),
              elevation: 0,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  HapticService.medium();
                  widget.onTap();
                },
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
