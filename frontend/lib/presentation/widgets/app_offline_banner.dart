import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Consistent offline/sync banner used across feature screens.
class AppOfflineBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppOfflineBanner({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      leading: Semantics(
        label: message,
        child: const Icon(Icons.cloud_off_outlined),
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: Text(AppStrings.retry),
          ),
      ],
    );
  }
}
