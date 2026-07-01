import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mudabbir/core/theme/app_theme.dart';
import 'package:mudabbir/presentation/resources/assets_manager.dart';
import 'package:mudabbir/service/getit_init.dart';
import 'package:mudabbir/service/routing_service/app_routes.dart';
import 'package:mudabbir/service/routing_service/auth_notifier.dart';

/// شاشة افتتاح مدبّر — شعار متحرك ثم توجيه حسب جلسة المستخدم.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _textOffset;
  late final Animation<double> _textOpacity;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _iconScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.1, 0.85, curve: Curves.elasticOut),
      ),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.1, 0.45, curve: Curves.easeOut),
      ),
    );
    _textOffset = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.42, 0.78, curve: Curves.easeOut),
      ),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.42, 0.78, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();
    unawaited(_checkAuth());
  }

  Future<void> _checkAuth() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await _waitUntilAuthReady();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted || _navigated) return;

    final auth = getIt<AuthNotifier>();
    _navigated = true;

    if (auth.isLoggedIn) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  Future<void> _waitUntilAuthReady() async {
    final auth = getIt<AuthNotifier>();
    if (auth.isInitialized) return;

    final completer = Completer<void>();
    late VoidCallback listener;
    listener = () {
      if (auth.isInitialized) {
        auth.removeListener(listener);
        if (!completer.isCompleted) completer.complete();
      }
    };
    auth.addListener(listener);
    await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.text1Dark : AppColors.text1;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Opacity(
                opacity: _iconOpacity.value,
                child: Transform.scale(
                  scale: _iconScale.value,
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusAppIcon),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.navy.withValues(alpha: 0.30),
                          blurRadius: 36,
                          offset: const Offset(0, 14),
                        ),
                        BoxShadow(
                          color: AppColors.navy.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusAppIcon),
                      child: Image.asset(
                        ImageAssets.appIcon,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Opacity(
                opacity: _textOpacity.value,
                child: Transform.translate(
                  offset: Offset(0, _textOffset.value),
                  child: Column(
                    children: [
                      Text(
                        'مدبّر',
                        style: AppText.bold(27, color: titleColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'دبّر مالك بذكاء',
                        style: AppText.regular(13, color: AppColors.text3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom + 24,
        ),
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.text4),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
