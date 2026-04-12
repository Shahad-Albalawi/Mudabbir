import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mudabbir/presentation/resources/theme_manager.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/hive_service.dart';
import 'package:mudabbir/service/language/app_language_controller.dart';
import 'package:mudabbir/service/notifications/push_notification_service.dart';
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
    await InstantBrowseBootstrap.applyIfEnabled();
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
        final isRtl = lang.locale.languageCode == 'ar';
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: getApplicationTheme(),
          darkTheme: getApplicationDarkTheme(),
          themeMode: getIt<AppThemeController>().themeMode,
          // Avoid TextStyle lerp crashes from mixed inherited styles while toggling theme.
          themeAnimationDuration: Duration.zero,
          themeAnimationCurve: Curves.linear,
          routerConfig: AppRouter.router,
          locale: lang.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
