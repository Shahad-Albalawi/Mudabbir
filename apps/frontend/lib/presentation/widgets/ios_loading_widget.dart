import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';

/// iOS-style loading indicator.
/// Uses Lottie when asset exists, otherwise CupertinoActivityIndicator.
class IOSLoadingWidget extends StatelessWidget {
  final double size;
  final bool useLottie;

  const IOSLoadingWidget({super.key, this.size = 48, this.useLottie = true});

  @override
  Widget build(BuildContext context) {
    if (useLottie) {
      return SizedBox(
        width: size,
        height: size,
        child: Lottie.asset('assets/lottie/loading.json', fit: BoxFit.contain),
      );
    }
    return CupertinoActivityIndicator(
      radius: size / 2,
      color: ColorManager.primary,
    );
  }
}

/// Full-screen loading with optional message
class IOSLoadingScreen extends StatelessWidget {
  final String? message;

  const IOSLoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IOSLoadingWidget(size: 64),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
