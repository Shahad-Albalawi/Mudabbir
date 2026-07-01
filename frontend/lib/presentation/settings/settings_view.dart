import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/constants/app_theme.dart';
import 'package:mudabbir/constants/app_version.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/core/theme/theme_provider.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/settings/widgets/settings_group_card.dart';
import 'package:mudabbir/presentation/settings/widgets/settings_profile_card.dart';
import 'package:mudabbir/presentation/settings/widgets/settings_tile.dart';
import 'package:mudabbir/presentation/widgets/app_confirm_dialog.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/widgets/app_snackbar.dart';
import 'package:mudabbir/features/auth/services/auth_service.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/language/app_language_controller.dart';
import 'package:mudabbir/service/notifications/notification_preferences.dart';
import 'package:mudabbir/service/reporting/financial_report_exporter.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:mudabbir/utils/user_display_name.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  bool _exporting = false;
  bool _notificationsEnabled = true;
  bool _notificationsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
  }

  Future<void> _loadNotificationPref() async {
    final enabled = await NotificationPreferences.isEnabled();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = enabled;
      _notificationsLoaded = true;
    });
  }

  Map<String, dynamic>? get _userInfo {
    final raw = getIt<HiveService>().getValue(HiveConstants.savedUserInfo);
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  String get _displayName =>
      UserDisplayName.fromSavedUserInfo(_userInfo);

  String get _email => _userInfo?['email']?.toString().trim() ?? '';

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => AppStrings.themeLight,
        ThemeMode.dark => AppStrings.themeDark,
        ThemeMode.system => AppStrings.themeSystem,
      };

  String get _languageLabel => AppStrings.isEnglishLocale
      ? AppStrings.languageEnglishOption
      : AppStrings.languageArabicOption;

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      await FinancialReportExporter().shareMonthlyReport();
      if (!mounted) return;
      AppSnackbar.success(AppStrings.settingsExportPdfSuccess);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(AppStrings.settingsExportPdfFail);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.settingsLogoutConfirmTitle,
      message: AppStrings.settingsLogoutConfirmMessage,
      confirmLabel: AppStrings.logout,
      cancelLabel: AppStrings.txCancel,
    );
    if (confirmed == true && mounted) {
      await getIt<AuthService>().logout();
    }
  }

  Future<void> _showProfileEditor() async {
    final controller = TextEditingController(text: _displayName);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.settingsEditProfile),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: AppStrings.settingsProfileNameLabel,
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.txCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.goalSaveChanges),
          ),
        ],
      ),
    );

    if (saved != true || !mounted) return;

    final name = controller.text.trim();
    final info = Map<String, dynamic>.from(_userInfo ?? {});
    info['name'] = name;
    await getIt<HiveService>().setValue(HiveConstants.savedUserInfo, info);
    if (!mounted) return;
    setState(() {});
    AppSnackbar.success(AppStrings.settingsProfileSaved);
  }

  Future<void> _showAppearancePicker() async {
    final current = ref.read(themeProvider);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  AppStrings.themePickerTitle,
                  textAlign: TextAlign.start,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            _pickerTile(
              ctx,
              label: AppStrings.themeLight,
              selected: current == ThemeMode.light,
              onTap: () => _applyThemeAndClose(ctx, ThemeMode.light),
            ),
            _pickerTile(
              ctx,
              label: AppStrings.themeDark,
              selected: current == ThemeMode.dark,
              onTap: () => _applyThemeAndClose(ctx, ThemeMode.dark),
            ),
            _pickerTile(
              ctx,
              label: AppStrings.themeSystem,
              selected: current == ThemeMode.system,
              onTap: () => _applyThemeAndClose(ctx, ThemeMode.system),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _applyThemeAndClose(BuildContext sheetContext, ThemeMode mode) {
    Navigator.pop(sheetContext);
    HapticService.light();
    ref.read(themeProvider.notifier).setThemeMode(mode);
  }

  Future<void> _showLanguagePicker() async {
    final controller = getIt<AppLanguageController>();
    final current = controller.locale.languageCode;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  AppStrings.languagePickerTitle,
                  textAlign: TextAlign.start,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            _pickerTile(
              ctx,
              label: AppStrings.languageArabicOption,
              selected: current == 'ar',
              onTap: () => _applyLocaleAndClose(ctx, 'ar'),
            ),
            _pickerTile(
              ctx,
              label: AppStrings.languageEnglishOption,
              selected: current == 'en',
              onTap: () => _applyLocaleAndClose(ctx, 'en'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _applyLocaleAndClose(BuildContext sheetContext, String code) {
    Navigator.pop(sheetContext);
    HapticService.light();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<AppLanguageController>().setLocale(code);
    });
  }

  Widget _pickerTile(
    BuildContext ctx, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: AppColors.navy1)
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final colors = context.colors;

    return AppGroupedScaffold(
      titleText: AppStrings.settingsTitle,
      largeTitle: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.pageGutter,
          12,
          AppLayout.pageGutter,
          AppLayout.bottomNavClearance,
        ),
        children: [
          SettingsProfileCard(
            displayName: _displayName,
            email: _email,
            onEdit: () {
              HapticService.light();
              _showProfileEditor();
            },
          ),
          const SizedBox(height: 16),
          SettingsGroupCard(
            children: [
              SettingsTile(
                icon: Icons.palette_outlined,
                iconColor: colors.primary,
                iconBackground: colors.primarySurface,
                label: AppStrings.settingsAppearance,
                value: _themeLabel(themeMode),
                trailing: Switch.adaptive(
                  value: themeMode == ThemeMode.dark,
                  activeTrackColor: colors.primary.withValues(alpha: 0.45),
                  activeThumbColor: colors.primary,
                  onChanged: (enabled) {
                    HapticService.light();
                    ref
                        .read(themeProvider.notifier)
                        .setDarkEnabled(enabled);
                  },
                ),
                showChevron: true,
                onTap: () {
                  HapticService.light();
                  _showAppearancePicker();
                },
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.language_rounded,
                iconColor: AppColors.info,
                iconBackground: colors.primarySurface,
                label: AppStrings.languagePickerTitle,
                value: _languageLabel,
                showChevron: true,
                onTap: () {
                  HapticService.light();
                  _showLanguagePicker();
                },
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.notifications_outlined,
                iconColor: AppColors.gold,
                iconBackground: AppColors.goldS,
                label: AppStrings.settingsNotificationsLabel,
                trailing: _notificationsLoaded
                    ? Switch.adaptive(
                        value: _notificationsEnabled,
                        activeTrackColor: colors.primary.withValues(alpha: 0.45),
                        activeThumbColor: colors.primary,
                        onChanged: (value) async {
                          HapticService.light();
                          setState(() => _notificationsEnabled = value);
                          await NotificationPreferences.setEnabled(value);
                        },
                      )
                    : const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsGroupCard(
            children: [
              SettingsTile(
                icon: Icons.picture_as_pdf_outlined,
                iconColor: AppColors.red,
                iconBackground: AppColors.orangeSurface,
                label: AppStrings.settingsExportPdf,
                showChevron: true,
                onTap: _exporting
                    ? null
                    : () {
                        HapticService.light();
                        _exportPdf();
                      },
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: AppColors.green,
                iconBackground: AppColors.greenS,
                label: AppStrings.settingsPrivacyPolicy,
                showChevron: true,
                onTap: () {
                  HapticService.light();
                  context.push(AppRoutes.privacyPolicy);
                },
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.description_outlined,
                iconColor: AppColors.navy3,
                iconBackground: AppColors.navySurface,
                label: AppStrings.settingsTermsLink,
                showChevron: true,
                onTap: () {
                  HapticService.light();
                  context.push(AppRoutes.termsOfService);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _confirmLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red,
                side: const BorderSide(color: AppColors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                AppStrings.logout,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.red,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              AppStrings.settingsVersionLabel(AppVersion.label),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.textTertiary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
