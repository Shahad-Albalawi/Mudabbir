import 'package:flutter/material.dart';
import 'package:mudabbir/constants/app_theme.dart';

/// Settings row — colored icon (start/RTL right), label, trailing value/control (end/RTL left).
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    this.value,
    this.trailing,
    this.showChevron = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String? value;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final endWidget = trailing ??
        (value != null
            ? Text(
                value!,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              _IconBadge(
                icon: icon,
                color: iconColor,
                background: iconBackground,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (endWidget != null) ...[
                const SizedBox(width: 8),
                endWidget,
              ],
              if (showChevron) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_left_rounded,
                  size: 22,
                  color: colors.textTertiary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 62,
      endIndent: 14,
      color: colors.border,
    );
  }
}
