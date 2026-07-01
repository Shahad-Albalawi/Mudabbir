import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/home/home_screen_provider.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/statistics/statistics_screen_provider.dart';
import 'package:mudabbir/presentation/statistics/statistics_viewmodel.dart';

/// Refreshes all financial dashboards after a transaction or goal change.
class FinancialRefresh {
  FinancialRefresh._();

  static Future<void> refreshAll(WidgetRef ref) async {
    await Future.wait([
      ref.read(homeProvider.notifier).reload(),
      ref.read(homeScreenProvider.notifier).load(force: true),
      ref.read(statisticsProvider.notifier).loadStatistics(force: true),
      ref.read(statisticsScreenProvider.notifier).load(force: true),
    ]);
  }
}
