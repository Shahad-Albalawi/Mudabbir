import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mudabbir/presentation/home/home_viewmodel.dart';
import 'package:mudabbir/presentation/statistics/statistics_viewmodel.dart';

/// Refreshes all financial dashboards after a transaction or goal change.
class FinancialRefresh {
  FinancialRefresh._();

  static Future<void> refreshAll(WidgetRef ref) async {
    await Future.wait([
      ref.read(homeProvider.notifier).reload(),
      ref.read(statisticsProvider.notifier).loadStatistics(),
    ]);
  }
}
