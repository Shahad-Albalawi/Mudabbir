import 'package:flutter/material.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/ios_dialog_style.dart';

/// Consistent confirmation dialog for destructive actions.
class AppConfirmDialog {
  AppConfirmDialog._();

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool destructive = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return Dialog(
          shape: IOSDialogStyle.dialogShape(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            decoration: IOSDialogStyle.surfaceDecoration(ctx),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IOSDialogStyle.header(ctx, title: title),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    message,
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: cancelLabel ?? AppStrings.txCancel,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(cancelLabel ?? AppStrings.txCancel),
                          ),
                        ),
                      ),
                      SizedBox(width: AppLayout.sectionGap),
                      Expanded(
                        child: Semantics(
                          button: true,
                          label: confirmLabel ?? AppStrings.delete,
                          child: FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: destructive
                                ? FilledButton.styleFrom(
                                    backgroundColor: scheme.error,
                                    foregroundColor: scheme.onError,
                                  )
                                : null,
                            child: Text(confirmLabel ?? AppStrings.delete),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result == true;
  }
}
