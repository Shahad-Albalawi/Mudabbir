import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';
import 'package:mudabbir/presentation/widgets/ios_loading_widget.dart';

/// Standard loading / error / empty / content switch for feature screens.
class AppAsyncView extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isEmpty;
  final Widget emptyState;
  final Widget child;

  const AppAsyncView({
    super.key,
    required this.isLoading,
    required this.child,
    this.errorMessage,
    this.onRetry,
    this.isEmpty = false,
    required this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const IOSLoadingScreen();
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return IOSEmptyState(
        icon: Icons.cloud_off_rounded,
        title: AppStrings.snackErrorTitle,
        subtitle: errorMessage!,
        buttonLabel: onRetry != null ? AppStrings.retry : null,
        onPressed: onRetry,
      );
    }

    if (isEmpty) {
      return emptyState;
    }

    return child;
  }
}
