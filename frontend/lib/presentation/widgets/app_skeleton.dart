import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/design_tokens.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';

/// Pulsing placeholder block for skeleton loading states.
class AppSkeletonBox extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  const AppSkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  State<AppSkeletonBox> createState() => _AppSkeletonBoxState();
}

class _AppSkeletonBoxState extends State<AppSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final alpha = scheme.skeletonPulseLow +
        (scheme.skeletonPulseHigh - scheme.skeletonPulseLow) * _opacity.value;
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: scheme.skeletonBase.withValues(alpha: alpha),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}

/// List-style skeleton for transaction/goal/budget screens.
class AppListSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsets padding;

  const AppListSkeleton({
    super.key,
    this.itemCount = 5,
    this.padding = const EdgeInsets.all(AppLayout.pageGutter),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.smd),
      itemBuilder: (_, __) => const AppSkeletonBox(height: 72),
    );
  }
}

/// Summary card skeleton for Home financial status.
class AppSummarySkeleton extends StatelessWidget {
  const AppSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.pageGutter),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            AppSkeletonBox(height: 18, width: 140),
            SizedBox(height: 12),
            AppSkeletonBox(height: 14, width: 100),
            SizedBox(height: 16),
            AppSkeletonBox(height: 12),
            SizedBox(height: 10),
            AppSkeletonBox(height: 12),
            SizedBox(height: 10),
            AppSkeletonBox(height: 12),
          ],
        ),
      ),
    );
  }
}

/// KPI row skeleton for statistics screen.
class AppKpiSkeleton extends StatelessWidget {
  const AppKpiSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: AppSkeletonBox(height: 88)),
        SizedBox(width: 8),
        Expanded(child: AppSkeletonBox(height: 88)),
        SizedBox(width: 8),
        Expanded(child: AppSkeletonBox(height: 88)),
      ],
    );
  }
}
