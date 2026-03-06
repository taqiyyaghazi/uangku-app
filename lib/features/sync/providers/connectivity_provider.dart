import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a stream of connectivity changes.
///
/// Connectivity plus v6.0+ returns a List of [ConnectivityResult].
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// A simpler provider that returns true if connected to any network.
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityProvider);

  return connectivityAsync.maybeWhen(
    data: (results) => results.any((r) => r != ConnectivityResult.none),
    orElse: () =>
        true, // Assume online if status is unknown/loading to avoid flickering alarms
  );
});
