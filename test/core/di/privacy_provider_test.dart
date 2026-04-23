import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/di/privacy_provider.dart';

void main() {
  group('PrivacyNotifier', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({'is_hidden': false});
    });

    test('build() initializes with value from SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_hidden', true);

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final isHidden = container.read(privacyProvider);
      expect(isHidden, isTrue);
    });

    test('togglePrivacy() flips the state and saves to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final notifier = container.read(privacyProvider.notifier);
      
      // Initial is false
      expect(container.read(privacyProvider), isFalse);
      
      // Toggle to true
      await notifier.togglePrivacy();
      expect(container.read(privacyProvider), isTrue);
      expect(prefs.getBool('is_hidden'), isTrue);
      
      // Toggle back to false
      await notifier.togglePrivacy();
      expect(container.read(privacyProvider), isFalse);
      expect(prefs.getBool('is_hidden'), isFalse);
    });
  });
}
