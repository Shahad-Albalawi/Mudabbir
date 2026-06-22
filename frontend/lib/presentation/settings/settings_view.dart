import 'package:flutter/material.dart';
import 'package:mudabbir/constants/hive_constants.dart';
import 'package:mudabbir/presentation/resources/app_layout.dart';
import 'package:mudabbir/presentation/widgets/app_grouped_scaffold.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/widgets/app_card.dart';
import 'package:mudabbir/presentation/widgets/app_confirm_dialog.dart';
import 'package:mudabbir/presentation/widgets/app_loading_button.dart';
import 'package:mudabbir/presentation/widgets/app_section_header.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/haptic_service.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/language/app_language_controller.dart';
import 'package:mudabbir/service/reporting/financial_report_exporter.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';
import 'package:mudabbir/service/theme/app_theme_controller.dart';
import 'package:mudabbir/utils/user_display_name.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _exporting = false;

  Map<String, dynamic>? get _userInfo {
    final raw = getIt<HiveService>().getValue(HiveConstants.savedUserInfo);
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  String get _displayName =>
      UserDisplayName.fromSavedUserInfo(_userInfo);

  String get _email => _userInfo?['email']?.toString().trim() ?? '';

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      await FinancialReportExporter().shareMonthlyReport();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.settingsExportPdfSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.settingsExportPdfFail),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      await getIt<AuthNotifier>().didLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = _displayName.isNotEmpty
        ? _displayName.characters.first.toUpperCase()
        : '?';

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
          AppSectionHeader(title: AppStrings.settingsAccountSection),
          const SizedBox(height: 8),
          AppCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Semantics(
                  label: _displayName,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.chromeIconFill,
                    child: Text(
                      initial,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName.isEmpty ? AppStrings.title : _displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (_email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.textMuted,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppLayout.sectionGap),
          AppSectionHeader(title: AppStrings.settingsPreferencesSection),
          const SizedBox(height: 8),
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                Semantics(
                  button: true,
                  label: AppStrings.themePickerTitle,
                  child: ListTile(
                    leading: Icon(Icons.brightness_6_outlined, color: scheme.chromeIcon),
                    title: Text(AppStrings.themePickerTitle),
                    trailing: Icon(Icons.chevron_right, color: scheme.textMuted),
                    onTap: () {
                      HapticService.light();
                      _showThemePicker(context);
                    },
                  ),
                ),
                Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
                Semantics(
                  button: true,
                  label: AppStrings.languagePickerTitle,
                  child: ListTile(
                    leading: Icon(Icons.language_outlined, color: scheme.chromeIcon),
                    title: Text(AppStrings.languagePickerTitle),
                    trailing: Icon(Icons.chevron_right, color: scheme.textMuted),
                    onTap: () {
                      HapticService.light();
                      _showLanguagePicker(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppLayout.sectionGap),
          AppSectionHeader(title: AppStrings.settingsLegalSection),
          const SizedBox(height: 8),
          AppCard(
            margin: EdgeInsets.zero,
            child: Semantics(
              button: true,
              label: AppStrings.settingsPrivacyPolicy,
              child: ListTile(
                leading: Icon(Icons.privacy_tip_outlined, color: scheme.chromeIcon),
                title: Text(AppStrings.settingsPrivacyPolicy),
                trailing: Icon(Icons.chevron_right, color: scheme.textMuted),
                onTap: () {
                  HapticService.light();
                  context.push(AppRoutes.privacyPolicy);
                },
              ),
            ),
          ),
          const SizedBox(height: AppLayout.sectionGap),
          AppLoadingButton(
            isLoading: _exporting,
            label: AppStrings.settingsExportPdf,
            onPressed: _exportPdf,
          ),
          const SizedBox(height: 12),
          Semantics(
            button: true,
            label: AppStrings.logout,
            child: OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: Icon(Icons.logout_rounded, color: scheme.error),
              label: Text(
                AppStrings.logout,
                style: TextStyle(color: scheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showThemePicker(BuildContext context) async {
    final controller = getIt<AppThemeController>();
    final current = controller.themeMode;
    final scheme = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
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
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            _sheetTile(
              ctx,
              icon: Icons.brightness_auto,
              label: AppStrings.themeSystem,
              selected: current == ThemeMode.system,
              scheme: scheme,
              onTap: () => _applyThemeAndClose(ctx, ThemeMode.system),
            ),
            _sheetTile(
              ctx,
              icon: Icons.light_mode_rounded,
              label: AppStrings.themeLight,
              selected: current == ThemeMode.light,
              scheme: scheme,
              onTap: () => _applyThemeAndClose(ctx, ThemeMode.light),
            ),
            _sheetTile(
              ctx,
              icon: Icons.dark_mode_rounded,
              label: AppStrings.themeDark,
              selected: current == ThemeMode.dark,
              scheme: scheme,
              onTap: () => _applyThemeAndClose(ctx, ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }

  /// Close sheet first — applying theme rebuilds [MaterialApp] and must not pop after.
  void _applyThemeAndClose(BuildContext sheetContext, ThemeMode mode) {
    Navigator.pop(sheetContext);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<AppThemeController>().setThemeMode(mode);
    });
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final controller = getIt<AppLanguageController>();
    final current = controller.locale.languageCode;
    final scheme = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
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
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            _sheetTile(
              ctx,
              icon: Icons.translate,
              label: AppStrings.languageArabicOption,
              selected: current == 'ar',
              scheme: scheme,
              onTap: () => _applyLocaleAndClose(ctx, 'ar'),
            ),
            _sheetTile(
              ctx,
              icon: Icons.translate,
              label: AppStrings.languageEnglishOption,
              selected: current == 'en',
              scheme: scheme,
              onTap: () => _applyLocaleAndClose(ctx, 'en'),
            ),
          ],
        ),
      ),
    );
  }

  void _applyLocaleAndClose(BuildContext sheetContext, String code) {
    Navigator.pop(sheetContext);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<AppLanguageController>().setLocale(code);
    });
  }

  Widget _sheetTile(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required bool selected,
    required ColorScheme scheme,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: scheme.chromeIcon),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: scheme.chromeIcon)
          : null,
      onTap: onTap,
    );
  }
}
