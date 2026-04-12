import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/challenges/challenges_viewmodel.dart';
import 'package:mudabbir/presentation/resources/color_manager.dart';
import 'package:mudabbir/presentation/resources/entity_localizations.dart';
import 'package:mudabbir/presentation/resources/modern_gradient_appbar.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/navigation_service.dart';
import 'package:mudabbir/service/popup_service/challenge_popup.dart';
import 'package:mudabbir/service/popup_service/popup_service.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/utils/user_display_name.dart';

class ChallengesView extends ConsumerWidget {
  const ChallengesView({super.key});

  // Method to show status update dialog
  void _showStatusUpdateDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> challenge,
  ) {
    final challengeViewmodel = ref.read(challengeViewmodelProvider.notifier);
    String? selectedStatus = challenge['status'];
    final List<String> statuses = ["نشط", "مكتمل", "ملغي"];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final dlgScheme = Theme.of(context).colorScheme;
            return AlertDialog(
              backgroundColor: dlgScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.update_outlined,
                      color: ColorManager.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.challengesUpdateTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dlgScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.challengeLine(challenge['name'].toString()),
                    style: TextStyle(
                      fontSize: 16,
                      color: dlgScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: dlgScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: dlgScheme.outline.withValues(alpha: 0.35),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: ColorManager.primary,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: dlgScheme.onSurface,
                        ),
                        items: statuses.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Row(
                              children: [
                                _getStatusIcon(status),
                                const SizedBox(width: 12),
                                Text(
                                  EntityLocalizations.challengeStatusLabel(
                                    status,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedStatus = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppStrings.txCancel,
                    style: TextStyle(
                      color: dlgScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (selectedStatus != null) {
                      await challengeViewmodel.updateChallengeStatus(
                        challenge['id'],
                        selectedStatus!,
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).pop();

                      getIt<NavigationService>().showSuccessSnackbar(
                        title: AppStrings.snackSuccessTitle,
                        body: AppStrings.challengesUpdatedSuccess,
                      );
                    }
                  },
                  child: Text(
                    AppStrings.challengesUpdateButton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _getStatusIcon(String status) {
    IconData iconData;
    Color color;

    switch (status) {
      case "نشط":
        iconData = Icons.play_circle_outline;
        color = ColorManager.primary;
        break;
      case "مكتمل":
        iconData = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case "ملغي":
        iconData = Icons.cancel_outlined;
        color = Colors.red;
        break;
      default:
        iconData = Icons.help_outline;
        color = ColorManager.textSecondary;
    }

    return Icon(iconData, color: color, size: 20);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "نشط":
        return ColorManager.primary;
      case "مكتمل":
        return Colors.green;
      case "ملغي":
        return Colors.red;
      default:
        return ColorManager.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeState = ref.watch(challengeViewmodelProvider);
    final challengeViewmodel = ref.read(challengeViewmodelProvider.notifier);

    ref.listen<ChallengeState>(challengeViewmodelProvider, (
      previousState,
      newState,
    ) async {
      if (newState.isDelete) {
        await challengeViewmodel.getAllChallenges();
        getIt<NavigationService>().showSuccessSnackbar(
          title: AppStrings.snackSuccessTitle,
          body: AppStrings.challengesDeletedSuccess,
        );
      }
      if (newState.isAdd == true) {
        await challengeViewmodel.getAllChallenges();
      }
      if (newState.isUpdate == true) {
        // Challenge updated successfully
      }
    });

    return Scaffold(
      appBar: ModernGradientAppBar(
        // backgroundColor: Color(0xfff6f5f5),
        showBackButton: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ColorManager.primaryWithOpacity12,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: ColorManager.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              () {
                final name = UserDisplayName.fromSavedUserInfo(
                  getIt<HiveService>().getValue(HiveConstants.savedUserInfo),
                );
                return name.isEmpty
                    ? AppStrings.title
                    : '${AppStrings.title} - $name';
              }(),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              await getIt<AuthNotifier>().didLogout();
            },
            icon: Icon(Icons.login),
          ),
        ],
      ),
      backgroundColor: ColorManager.background,
      body: Builder(
        builder: (context) {
          // Loading
          if (challengeState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state (no challenges)
          if (challengeState.challenges.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.emoji_events_outlined,
                      size: 50,
                      color: ColorManager.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "لا توجد تحديات",
                    style: TextStyle(
                      fontSize: 20,
                      color: ColorManager.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "ابدأ بإضافة تحدي مالي جديد",
                    style: TextStyle(
                      fontSize: 16,
                      color: ColorManager.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      ChallengePopup().show(context, ref);
                    },
                    child: const Text(
                      "إضافة تحدي جديد",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Challenges exist → show "Add" button + list
          return Column(
            children: [
              // Add Challenge Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: ColorManager.primary.withValues(alpha: 0.14),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      getIt<PopupService>().showAddChallengePopup(context, ref);
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      AppStrings.challengesAddNewButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // Challenges List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: challengeState.challenges.length,
                  itemBuilder: (ctx, i) {
                    final challenge = challengeState.challenges[i];
                    final status = challenge['status'] ?? 'نشط';
                    final startDate = challenge['start_date'] ?? '';
                    final endDate = challenge['end_date'] ?? '';
                    final scheme = Theme.of(ctx).colorScheme;

                    return GestureDetector(
                      onTap: () {
                        _showStatusUpdateDialog(ctx, ref, challenge);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Challenge Header
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ColorManager.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.emoji_events_outlined,
                                      color: ColorManager.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "${challenge['name']}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await challengeViewmodel.deleteChallenge(
                                        challenge['id'],
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: ColorManager.error,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Status Badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        status,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: _getStatusColor(
                                          status,
                                        ).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _getStatusIcon(status),
                                        const SizedBox(width: 6),
                                        Text(
                                          EntityLocalizations
                                              .challengeStatusLabel(status),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _getStatusColor(status),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Date Info
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest
                                      .withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_outlined,
                                                size: 14,
                                                color:
                                                    scheme.onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                AppStrings.challengesStartLabel,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            startDate,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: scheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 30,
                                      color: scheme.outline.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.event_outlined,
                                                size: 14,
                                                color:
                                                    scheme.onSurfaceVariant,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                AppStrings.challengesEndLabel,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            endDate,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: scheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Tap Hint
                              Center(
                                child: Text(
                                  "اضغط لتحديث الحالة",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: ColorManager.primary.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
