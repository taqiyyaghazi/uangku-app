import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/settings_repository.dart';
import 'package:uangku/features/dashboard/logic/settings_providers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:mockito/mockito.dart';

class MockAnalytics extends Mock implements FirebaseAnalytics {}

class MockCrashlytics extends Mock implements FirebaseCrashlytics {}

class MockMonitoringService extends MonitoringService {
  MockMonitoringService() : super(MockAnalytics(), MockCrashlytics());

  @override
  void logInfo(String message, [Map<String, dynamic>? extra]) {}

  @override
  void logError(
    String message,
    dynamic error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  ]) {}
}

void main() {
  late AppDatabase db;
  late SettingsRepository repository;
  late ProviderContainer container;
  late MockMonitoringService monitoring;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    monitoring = MockMonitoringService();
    // In actual tests, we might want to mock syncRepo too if needed
    repository = SettingsRepository(db, monitoring);

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        monitoringServiceProvider.overrideWithValue(monitoring),
        settingsRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('Settings Providers & Repository', () {
    test(
      'monthlyBudgetProvider emits 0.0 by default if key does not exist',
      () async {
        // Act & Assert
        final sub = container.listen(monthlyBudgetProvider, (_, _) {});

        // Wait for stream to emit default 0.0 mapped value
        await expectLater(
          container.read(monthlyBudgetProvider.future),
          completion(0.0),
        );

        sub.close();
      },
    );

    test('settingsRepository can setDouble and watchDouble reads it', () async {
      // Act
      await repository.setDouble('test_key', 42.5);

      // Assert
      final stream = repository.watchDouble('test_key');
      await expectLater(stream, emits(42.5));
    });

    test(
      'monthlyBudgetProvider reactively updates when repository is modified',
      () async {
        // Listen to ensure the provider is active before we make changes.
        final sub = container.listen(monthlyBudgetProvider, (_, _) {});

        // Act
        await repository.setDouble('monthly_budget', 7500000.0);

        // Wait for stream value
        final value = await container.read(monthlyBudgetProvider.future);

        // Assert
        expect(value, 7500000.0);

        sub.close();
      },
    );
  });
}
