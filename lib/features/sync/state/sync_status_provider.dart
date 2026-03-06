import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/di/providers.dart';
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
  @override
  SyncStatusState build() => SyncStatusState.idle();

  Future<void> restoreDataIfNeeded() async {
    // 1. If we are already syncing or have attempted restoration in this session, do nothing.
    if (state.status == SyncStatus.syncing || state.hasAttemptedRestoration) {
      return;
    }

    // 2. Check if auth is ready
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    // 3. Check if local DB is empty (specifically wallets)
    try {
      final wallets = await ref
          .read(walletRepositoryProvider)
          .watchAllWallets()
          .first;

      if (wallets.isNotEmpty) {
        // Data already exists, mark as attempted to prevent redundant checks.
        state = state.copyWith(hasAttemptedRestoration: true);
        return;
      }
    } catch (e) {
      developer.log(
        'Database check failed',
        name: 'SyncStatusNotifier',
        error: e,
      );
      return;
    }

    // 4. Start Sync
    state = SyncStatusState.syncing('Restoring your data from cloud...');

    try {
      final repository = ref.read(syncRepositoryProvider);
      await repository.syncFromCloud();
      state = SyncStatusState.completed();
    } catch (e) {
      developer.log('Restoration failed', name: 'SyncStatusNotifier', error: e);
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
