import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/features/dashboard/logic/settings_providers.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/features/auth/state/auth_provider.dart';

enum SyncStatus { idle, syncing, completed, error }

class SyncStatusState {
  final SyncStatus status;
  final String? message;
  final bool hasAttemptedRestoration;

  SyncStatusState({
    required this.status,
    this.message,
    this.hasAttemptedRestoration = false,
  });

  factory SyncStatusState.idle() => SyncStatusState(status: SyncStatus.idle);
  factory SyncStatusState.syncing(String message) => SyncStatusState(
    status: SyncStatus.syncing,
    message: message,
    hasAttemptedRestoration: false,
  );
  factory SyncStatusState.completed({bool attempted = true}) => SyncStatusState(
    status: SyncStatus.completed,
    hasAttemptedRestoration: attempted,
  );
  factory SyncStatusState.error(String message) => SyncStatusState(
    status: SyncStatus.error,
    message: message,
    hasAttemptedRestoration: true,
  );

  SyncStatusState copyWith({
    SyncStatus? status,
    String? message,
    bool? hasAttemptedRestoration,
  }) {
    return SyncStatusState(
      status: status ?? this.status,
      message: message ?? this.message,
      hasAttemptedRestoration:
          hasAttemptedRestoration ?? this.hasAttemptedRestoration,
    );
  }
}

class SyncStatusNotifier extends Notifier<SyncStatusState> {
  MonitoringService get _monitoring => ref.read(monitoringServiceProvider);

  @override
  SyncStatusState build() {
    // Proactively check if restoration is needed when this provider is first watched.
    // This makes the sync trigger more declarative.
    Future.microtask(() => restoreDataIfNeeded());
    return SyncStatusState.idle();
  }

  Future<void> restoreDataIfNeeded() async {
    // 1. If we are already syncing or have attempted restoration in this session, do nothing.
    if (state.status == SyncStatus.syncing || state.hasAttemptedRestoration) {
      return;
    }

    // 2. Check if auth is ready
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    // 3. Check if local DB has data (specifically wallets)
    try {
      final wallets = await ref
          .read(walletRepositoryProvider)
          .watchAllWallets()
          .first;

      if (wallets.isNotEmpty) {
        // Data exists locally. Check if we need to push it to cloud.
        final settingsRepo = ref.read(settingsRepositoryProvider);
        final isPushed = await settingsRepo.isInitialPushCompleted();

        if (!isPushed) {
          _monitoring.logInfo(
            'Local data exists but not pushed to cloud yet. Starting push...',
          );
          state = SyncStatusState.syncing('Backing up your data to cloud...');

          final syncRepo = ref.read(syncRepositoryProvider);
          await syncRepo.pushAllToCloud();
          await settingsRepo.markInitialPushCompleted();

          _monitoring.logInfo('Local data push completed.');
        } else {
          _monitoring.logInfo(
            'Data already exists and pushed, skipping cloud sync actions',
          );
        }

        state = state.copyWith(
          status: SyncStatus.idle,
          hasAttemptedRestoration: true,
        );
        return;
      }
    } catch (e, st) {
      _monitoring.logError(
        'Database check failed during restoration check',
        e,
        st,
      );
      return;
    }

    // 4. Start Sync
    _monitoring.logInfo('Starting cloud data restoration...');
    state = SyncStatusState.syncing('Restoring your data from cloud...');

    try {
      final repository = ref.read(syncRepositoryProvider);
      await repository.syncFromCloud();
      _monitoring.logInfo('Cloud restoration completed successfully');
      state = SyncStatusState.completed();
    } catch (e, st) {
      _monitoring.logError('Restoration failed', e, st);
      state = SyncStatusState.error(
        'Failed to restore data. Please check your connection.',
      );
    }
  }

  void reset() {
    state = state.copyWith(status: SyncStatus.idle);
  }

  /// Explicitly reset everything, e.g. on logout/login.
  void fullReset() {
    state = SyncStatusState.idle();
  }
}

final syncStatusProvider =
    NotifierProvider<SyncStatusNotifier, SyncStatusState>(
      SyncStatusNotifier.new,
    );
