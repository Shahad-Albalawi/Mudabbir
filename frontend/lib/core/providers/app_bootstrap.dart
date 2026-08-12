import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mudabbir/core/providers/app_providers.dart';
import 'package:mudabbir/core/providers/provider_reader.dart';

/// Initializes Hive caches and language prefs using the root [ProviderContainer].
Future<void> bootstrapApp(ProviderContainer container) async {
  bindProviderContainer(container);

  await container.read(appLanguageControllerProvider).load();
  await container.read(hiveServiceProvider).init();
  await container.read(challengeHiveCacheProvider).init();
  await container.read(challengeHiveCacheProvider).migrateLegacyProgress(
        Hive.box('myBox').toMap(),
      );
  await container.read(expenseHiveCacheProvider).init();
  await container.read(budgetHiveCacheProvider).init();
  await container.read(goalHiveCacheProvider).init();
}

/// Test helper — registers overrides on a fresh container.
ProviderContainer createTestContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(overrides: overrides);
  bindProviderContainer(container);
  return container;
}
