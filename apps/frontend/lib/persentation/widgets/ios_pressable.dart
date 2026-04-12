import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mudabbir/persentation/resources/ios_style_constants.dart';

/// Wraps a child with press scale animation and haptic feedback.
class IOSPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableHaptic;
  final double scaleDown;

  const IOSPressable({
    super.key,
    required this.child,
    this.onTap,
    this.enableHaptic = true,
    this.scaleDown = IOSStyleConstants.pressScale,
  });

  @override
  State<IOSPressable> createState() => _IOSPressableState();
}

class _IOSPressableState extends State<IOSPressable> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  void _onTap() {
    if (widget.enableHaptic) {
      HapticFeedback.selectionClick();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap != null ? _onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleDown : 1.0,
        duration: const Duration(
          milliseconds: IOSStyleConstants.durationFast,
        ),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
