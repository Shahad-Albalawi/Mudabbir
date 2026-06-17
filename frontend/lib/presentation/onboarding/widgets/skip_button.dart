import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

class SkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const SkipButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: scheme.textMuted,
          backgroundColor: scheme.surface.withValues(alpha: 0.85),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(color: scheme.outline.withValues(alpha: 0.3)),
          ),
        ),
        icon: Icon(
          AppStrings.isEnglishLocale
              ? Icons.arrow_forward
              : Icons.arrow_back,
          size: 16,
        ),
        label: Text(
          AppStrings.skip,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
