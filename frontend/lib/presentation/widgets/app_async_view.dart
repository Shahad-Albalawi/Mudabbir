import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_skeleton.dart';
import 'package:mudabbir/presentation/widgets/ios_empty_state.dart';

/// Standard loading / error / empty / content switch for feature screens.
class AppAsyncView extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isEmpty;
  final Widget emptyState;
  final Widget child;

  final String? loadingLabel;
  final Widget? loading;

  const AppAsyncView({
    super.key,
    required this.isLoading,
    required this.child,
    this.errorMessage,
    this.onRetry,
    this.isEmpty = false,
    required this.emptyState,
    this.loadingLabel,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Semantics(
        container: true,
        label: loadingLabel ?? AppStrings.loading,
        child: loading ?? const AppListSkeleton(),
      );
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
