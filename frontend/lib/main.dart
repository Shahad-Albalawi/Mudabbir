import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mudabbir/data/local/budget_hive_cache.dart';
import 'package:mudabbir/data/local/challenge_hive_cache.dart';
import 'package:mudabbir/data/local/expense_hive_cache.dart';
import 'package:mudabbir/data/local/goal_hive_cache.dart';
import 'package:mudabbir/l10n/app_localizations.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/resources/app_fonts.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/resources/theme_manager.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/language/app_language_controller.dart';
import 'package:mudabbir/service/notifications/push_notification_service.dart';
import 'package:mudabbir/service/debug/dev_api_bootstrap.dart';
import 'package:mudabbir/service/debug/instant_browse_bootstrap.dart';
import 'package:mudabbir/service/routing_service/app_router.dart';
import 'package:mudabbir/service/theme/app_theme_controller.dart';
import 'package:mudabbir/utils/dev_log.dart';

// --- App entry: DI, Hive, theme prefs, optional push, then Riverpod.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    setupLocator();
    await getIt<AppThemeController>().load();
    await getIt<AppLanguageController>().load();
    await SystemChrome.setPreferredOrientations([]);
    await Hive.initFlutter();
    await getIt<HiveService>().init();
    await getIt<ChallengeHiveCache>().init();
    await getIt<ChallengeHiveCache>().migrateLegacyProgress(
      Hive.box('myBox').toMap(),
    );
    await getIt<ExpenseHiveCache>().init();
    await getIt<BudgetHiveCache>().init();
    await getIt<GoalHiveCache>().init();
    await AppFonts.ensureLoaded();
    await InstantBrowseBootstrap.applyIfEnabled();
    await DevApiBootstrap.logAndProbe();
    await PushNotificationService.instance.initializeIfConfigured();
  } catch (e, stack) {
    devLog('Initialization error: $e\n$stack');
    rethrow;
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        getIt<AppThemeController>(),
        getIt<AppLanguageController>(),
      ]),
      builder: (context, _) {
        final lang = getIt<AppLanguageController>();
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: getApplicationTheme(),
          darkTheme: getApplicationDarkTheme(),
          themeMode: getIt<AppThemeController>().themeMode,
          // Short cross-fade when switching light/dark (avoids TextStyle lerp glitches).
          themeAnimationDuration: const Duration(milliseconds: 220),
          themeAnimationCurve: Curves.easeOutCubic,
          routerConfig: AppRouter.router,
          locale: lang.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            AppStrings.bind(AppLocalizations.of(context));
            final rtl = lang.locale.languageCode == 'ar';
            final scaledChild = MediaQuery.withClampedTextScaling(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.35,
              child: child ?? const SizedBox.shrink(),
            );
            return Directionality(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontFamily: FontConstants.thmanyahFamily,
                  fontFamilyFallback: FontConstants.fontFamilyFallback,
                ),
                child: scaledChild,
              ),
            );
          },
        );
      },
    );
  }
}
