import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/settings_repository.dart';
import 'package:uangku/features/dashboard/logic/settings_providers.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repository;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SettingsRepository(db);

    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
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
        final sub = container.listen(monthlyBudgetProvider, (_, __) {});

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
        // Act
        await repository.setDouble('monthly_budget', 7500000.0);

        // Wait for stream value
        final value = await container.read(monthlyBudgetProvider.future);

        // Assert
        expect(value, 7500000.0);
      },
    );
  });
}
