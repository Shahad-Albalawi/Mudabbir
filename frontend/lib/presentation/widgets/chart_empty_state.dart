import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';

/// Chart / statistics empty placeholder — delegates to [IOSEmptyState].
class ChartEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final double height;

  const ChartEmptyState({
    super.key,
    this.icon = Icons.pie_chart_outline_rounded,
    required this.message,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Center(
        child: IOSEmptyState(
          icon: icon,
          title: message,
          compact: true,
          animate: false,
        ),
      ),
    );
  }
}
