import 'package:flutter_riverpod/flutter_riverpod.dart';

ProviderContainer? _container;

/// Binds the root [ProviderContainer] during app bootstrap (see [bootstrapApp]).
void bindProviderContainer(ProviderContainer container) {
  _container = container;
}

/// Reads a provider outside the widget tree (services, utils, domain wiring).
T readApp<T>(ProviderListenable<T> provider) {
  final container = _container;
  if (container == null) {
    throw StateError(
      'ProviderContainer is not initialized. Call bootstrapApp() first.',
    );
  }
  return container.read(provider);
}

/// Resets the container binding — for tests only.
void resetProviderContainerBinding() {
  _container = null;
}
