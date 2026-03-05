import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for monitoring application stability (Crashlytics) and usage (Analytics).
///
/// This service abstracts Firebase tools to enable "Testability-First Design"
/// and consistent observability across the app.
class MonitoringService {
  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;

  MonitoringService(this._analytics, this._crashlytics);

  /// Returns the [FirebaseAnalyticsObserver] for automatic screen tracking.
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // --- ANALYTICS ---

  /// Tracks a custom event with optional parameters.
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (kDebugMode) {
      debugPrint('Analytics Event: $name | $parameters');
    }
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  /// Sets the user ID for both Analytics and Crashlytics.
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
    await _crashlytics.setUserIdentifier(userId ?? '');
  }

  /// Sets a user property.
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // --- CRASHLYTICS ---

  /// Records a non-fatal error to Crashlytics.
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint('Crashlytics Error: $exception\nReason: $reason');
    }
    await _crashlytics.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  /// Adds a custom log message to the next crash report.
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }
}

/// Provider for [MonitoringService].
final monitoringServiceProvider = Provider<MonitoringService>((ref) {
  // Use .instance to satisfy actual Firebase requirements in production.
  return MonitoringService(
    FirebaseAnalytics.instance,
    FirebaseCrashlytics.instance,
  );
});
