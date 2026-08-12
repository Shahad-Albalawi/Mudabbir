import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mudabbir/core/providers/app_bootstrap.dart';
import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/core/router/app_router.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/core/theme/theme_provider.dart';
import 'package:mudabbir/l10n/app_localizations.dart';
import 'package:mudabbir/presentation/resources/app_fonts.dart';
import 'package:mudabbir/presentation/resources/font_manager.dart';
import 'package:mudabbir/presentation/resources/saudi_riyal_font.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';
import 'package:mudabbir/presentation/security/app_lock_overlay.dart';
import 'package:mudabbir/service/backend_warmup_service.dart';
import 'package:mudabbir/service/debug/dev_api_bootstrap.dart';
import 'package:mudabbir/service/debug/instant_browse_bootstrap.dart';
import 'package:mudabbir/service/notifications/push_notification_service.dart';
import 'package:mudabbir/utils/dev_log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final initialTheme = await ThemeNotifier.loadStored();
  final container = ProviderContainer(
    overrides: [
      themeProvider.overrideWith(
        (ref) => ThemeNotifier(initial: initialTheme),
      ),
    ],
  );

  try {
    await Hive.initFlutter();
    await Hive.openBox('prefs');
    await bootstrapApp(container);
    await AppFonts.ensureLoaded();
    await SaudiRiyalFont.probe();
    await InstantBrowseBootstrap.applyIfEnabled();
  } catch (e, stack) {
    devLog('Initialization error: $e\n$stack');
    container.dispose();
    rethrow;
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MudabbirApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(BackendWarmupService.wakeRenderBackend());
    unawaited(DevApiBootstrap.logAndProbe());
    unawaited(PushNotificationService.instance.initializeIfConfigured());
  });
}

class MudabbirApp extends ConsumerWidget {
  const MudabbirApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    final lang = ref.watch(appLanguageControllerProvider);
    final rtl = lang.locale.languageCode == 'ar';

    return MaterialApp.router(
      title: 'مدبّر',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 220),
      themeAnimationCurve: Curves.easeOutCubic,
      locale: lang.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        AppStrings.bind(AppLocalizations.of(context));
        final scaledChild = MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.35,
          child: child ?? const SizedBox.shrink(),
        );
        return Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: FontConstants.fontFamily,
              fontFamilyFallback: FontConstants.fontFamilyFallback,
            ),
            child: AppLockOverlay(child: scaledChild),
          ),
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;

    return base.copyWith(
      scaffoldBackgroundColor: isDark ? AppColors.bgDark : AppColors.bg,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.bold(
          17,
          color: isDark ? AppColors.text1Dark : AppColors.text1,
        ),
      ),
    );
  }
}
