import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernGradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final double height;

  const ModernGradientAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.height = 56,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? const Color(0xFF202723).withValues(alpha: 0.92)
        : const Color(0xFFF8FAF7).withValues(alpha: 0.92);
    final iconFg = Theme.of(context).colorScheme.onSurface;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: preferredSize.height + MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border(
              bottom: BorderSide(
                color: iconFg.withValues(alpha: isDark ? 0.14 : 0.10),
                width: 0.7,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: height,
            centerTitle: centerTitle,
            systemOverlayStyle: isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,

            // Leading widget
            leading:
                leading ??
                (showBackButton && Navigator.of(context).canPop()
                    ? IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: iconFg,
                          size: 20,
                        ),
                        onPressed:
                            onBackPressed ?? () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: iconFg.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    : null),

            // Title
            title: title,

            // Actions
            actions: actions?.map((action) {
              if (action is IconButton) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: action.icon,
                    onPressed: action.onPressed,
                    color: iconFg,
                    iconSize: 22,
                    style: IconButton.styleFrom(
                      backgroundColor: iconFg.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                );
              }
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: action,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + 8);
}
