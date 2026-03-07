import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/services/monitoring_service.dart';

/// A global observer for Riverpod that catches and logs all unhandled provider errors.
///
/// This ensures that errors within asynchronous providers (like FutureProvider
/// or AsyncNotifier) are automatically reported to Crashlytics, even if they
/// are technically "caught" and handled gracefully by the UI layer (.when/error).
final class AppProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    // Avoid re-throwing, just log to our MonitoringService.
    try {
      final monitoringService = context.container.read(
        monitoringServiceProvider,
      );
      final providerName =
          context.provider.name ?? context.provider.runtimeType;
      monitoringService.logError(
        'Provider failed: $providerName',
        error,
        stackTrace,
      );
    } catch (e) {
      // Fallback if monitoring service fails or isn't available yet.
      debugPrint('Fallback error log - Provider failed: $error');
      debugPrint(stackTrace.toString());
    }
  }
}
