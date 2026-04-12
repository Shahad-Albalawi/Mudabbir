import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/challenges/challenges_viewmodel.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/server_challenge_strings.dart';
import 'package:mudabbir/service/popup_service/popup_widgets.dart';

class ChallengePopup {
  Future<void> show(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();

    final nameCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();

    String? selectedStatus;
    final List<String> statuses =
        ServerChallengeStrings.localStatusStorageValues;

    // ViewModel
    final challengeViewmodel = ref.read(challengeViewmodelProvider.notifier);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 24,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 550),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        ColorManager.primary,
                        ColorManager.primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.emoji_events_outlined,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ServerChallengeStrings.localPopupTitle,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ServerChallengeStrings.localPopupSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary.withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader(
                          context,
                          ServerChallengeStrings.localNameSection,
                        ),
                        const SizedBox(height: 12),
                        PopupWidgets.textField(
                          controller: nameCtrl,
                          label: ServerChallengeStrings.localNameHint,
                          icon: Icons.text_fields,
                          validator: (val) =>
                              val == null || val.isEmpty
                                  ? ServerChallengeStrings.localNameRequired
                                  : null,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionHeader(
                          context,
                          ServerChallengeStrings.localStatusSection,
                        ),
                        const SizedBox(height: 12),
                        PopupWidgets.dropdownField<String>(
                          value: selectedStatus,
                          label: ServerChallengeStrings.localStatusHint,
                          items: statuses,
                          itemLabel: ServerChallengeStrings.localStatusLabel,
                          onChanged: (val) => selectedStatus = val,
                          validator: (val) =>
                              val == null
                                  ? ServerChallengeStrings.localStatusRequired
                                  : null,
                        ),
                        const SizedBox(height: 20),

                        _buildSectionHeader(
                          context,
                          ServerChallengeStrings.localPeriodSection,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: PopupWidgets.dateField(
                                startCtrl,
                                context,
                                label: ServerChallengeStrings.localStartDate,
                                validator: (val) => val == null || val.isEmpty
                                    ? ServerChallengeStrings.localStartRequired
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PopupWidgets.dateField(
                                endCtrl,
                                context,
                                label: ServerChallengeStrings.localEndDate,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return ServerChallengeStrings
                                        .localEndRequired;
                                  }
                                  if (startCtrl.text.isNotEmpty) {
                                    final start = DateTime.tryParse(
                                      startCtrl.text,
                                    );
                                    final end = DateTime.tryParse(val);
                                    if (start != null &&
                                        end != null &&
                                        end.isBefore(start)) {
                                      return ServerChallengeStrings
                                          .localEndAfterStart;
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(ServerChallengeStrings.localCancel),
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!(formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            final challengeData = {
                              "name": nameCtrl.text,
                              "status": selectedStatus,
                              "start_date": startCtrl.text,
                              "end_date": endCtrl.text,
                            };

                            try {
                              await challengeViewmodel.addNewChallenge(
                                challengeData,
                              );
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              PopupWidgets.showSuccessSnackBar(
                                context,
                                ServerChallengeStrings.localCreateSuccess,
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              PopupWidgets.showErrorSnackBar(
                                context,
                                ServerChallengeStrings.localCreateFailed(e),
                              );
                            }
                          },
                          child: Text(ServerChallengeStrings.localCreateButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: ColorManager.primary,
      ),
    );
  }
}
