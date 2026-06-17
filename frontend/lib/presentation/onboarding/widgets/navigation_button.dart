import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;

  const NavigationButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.onPrimary.withValues(alpha: isEnabled ? 0.18 : 0.08),
        ),
        child: Center(
          child: Icon(
            icon,
            color: scheme.onPrimary.withValues(alpha: isEnabled ? 1 : 0.4),
            size: 20,
          ),
        ),
      ),
    );
  }
}
