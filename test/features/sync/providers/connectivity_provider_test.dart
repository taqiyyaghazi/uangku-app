import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/features/sync/providers/connectivity_provider.dart';

void main() {
  group('ConnectivityProvider', () {
    test('isOnlineProvider returns true when connectivity is not none', () {
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value([ConnectivityResult.wifi]),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Initially loading, should assume online to avoid false alarms
      expect(container.read(isOnlineProvider), true);

      // Wait for stream value
      container.listen(isOnlineProvider, (_, _) {}, fireImmediately: true);

      expect(container.read(isOnlineProvider), true);
    });

    test('isOnlineProvider returns false when connectivity is none', () async {
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value([ConnectivityResult.none]),
          ),
        ],
      );

      await container.read(connectivityProvider.future);
      expect(container.read(isOnlineProvider), false);
      container.dispose();
    });

    test('isOnlineProvider handles multiple results', () async {
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value([
              ConnectivityResult.wifi,
              ConnectivityResult.none,
            ]),
          ),
        ],
      );

      await container.read(connectivityProvider.future);
      expect(container.read(isOnlineProvider), true);
      container.dispose();
    });
  });
}
