import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/repositories/settings_repository.dart';

/// Provider for the [SettingsRepository].
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final monitoring = ref.watch(monitoringServiceProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  return SettingsRepository(db, monitoring, syncRepo);
});

/// Provides a stream of the user's configured monthly budget.
///
/// If no budget is configured, defaults to 0.0.
final monthlyBudgetProvider = StreamProvider<double>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchDouble('monthly_budget').map((value) => value ?? 0.0);
});
