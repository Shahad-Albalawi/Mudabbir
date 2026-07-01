import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';

/// Grouped settings card — white surface, light border, stacked tiles.
class SettingsGroupCard extends StatelessWidget {
  const SettingsGroupCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
