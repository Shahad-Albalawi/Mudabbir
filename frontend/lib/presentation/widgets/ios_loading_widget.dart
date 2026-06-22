import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';

/// iOS-style loading indicator used app-wide.
class IOSLoadingWidget extends StatelessWidget {
  final double size;

  const IOSLoadingWidget({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CupertinoActivityIndicator(
      radius: size / 2.8,
      color: scheme.chromeIcon,
    );
  }
}

/// Full-screen loading with optional message.
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
              style: TextStyle(color: scheme.textMuted, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
