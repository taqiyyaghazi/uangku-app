import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/features/sync/providers/connectivity_provider.dart';

void main() {
  group('ConnectivityProvider', () {
    test(
      'isOnlineProvider returns true when connectivity is not none',
      () async {
        final controller = StreamController<List<ConnectivityResult>>();
        final container = ProviderContainer(
          overrides: [
            connectivityProvider.overrideWith((ref) => controller.stream),
          ],
        );
        addTearDown(() {
          controller.close();
          container.dispose();
        });

        // Initially loading, should assume online to avoid false alarms
        expect(container.read(isOnlineProvider), true);

        // Add actual value and wait for stream listener to process it
        controller.add([ConnectivityResult.wifi]);
        container.listen(isOnlineProvider, (_, _) {}, fireImmediately: true);
        await Future.delayed(Duration.zero);

        expect(container.read(isOnlineProvider), true);
      },
    );

    test('isOnlineProvider returns false when connectivity is none', () async {
      final controller = StreamController<List<ConnectivityResult>>();
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith((ref) => controller.stream),
        ],
      );
      addTearDown(() {
        controller.close();
        container.dispose();
      });

      // Listen to keep provider alive and process stream events
      container.listen(isOnlineProvider, (_, _) {}, fireImmediately: true);

      controller.add([ConnectivityResult.none]);
      await Future.delayed(Duration.zero);

      expect(container.read(isOnlineProvider), false);
    });

    test('isOnlineProvider handles multiple results', () async {
      final controller = StreamController<List<ConnectivityResult>>();
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith((ref) => controller.stream),
        ],
      );
      addTearDown(() {
        controller.close();
        container.dispose();
      });

      container.listen(isOnlineProvider, (_, _) {}, fireImmediately: true);

      controller.add([ConnectivityResult.wifi, ConnectivityResult.none]);
      await Future.delayed(Duration.zero);

      expect(container.read(isOnlineProvider), true);
    });
  });
}
