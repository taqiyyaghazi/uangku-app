import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/di/providers.dart';

/// Notifier to manage the global privacy mode state (Hide Balances).
class PrivacyNotifier extends Notifier<bool> {
  static const _key = 'is_hidden';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  /// Toggles the privacy mode and saves the state to SharedPreferences.
  Future<void> togglePrivacy() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final newValue = !state;
    await prefs.setBool(_key, newValue);
    state = newValue;
  }
}

/// Provider for the global privacy mode state.
final privacyProvider = NotifierProvider<PrivacyNotifier, bool>(() {
  return PrivacyNotifier();
});
