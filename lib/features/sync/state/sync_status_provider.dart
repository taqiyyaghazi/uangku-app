import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/features/auth/state/auth_provider.dart';

enum SyncStatus { idle, syncing, completed, error }

class SyncStatusState {
  final SyncStatus status;
  final String? message;

  SyncStatusState({required this.status, this.message});

  factory SyncStatusState.idle() => SyncStatusState(status: SyncStatus.idle);
  factory SyncStatusState.syncing(String message) =>
      SyncStatusState(status: SyncStatus.syncing, message: message);
  factory SyncStatusState.completed() =>
      SyncStatusState(status: SyncStatus.completed);
  factory SyncStatusState.error(String message) =>
      SyncStatusState(status: SyncStatus.error, message: message);
}

class SyncStatusNotifier extends Notifier<SyncStatusState> {
  @override
  SyncStatusState build() => SyncStatusState.idle();

  Future<void> restoreDataIfNeeded() async {
    // 1. Check if auth is ready
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    // 2. Check if local DB is empty (specifically wallets which are not seeded)
    final wallets = await ref
        .read(walletRepositoryProvider)
        .watchAllWallets()
        .first;
    if (wallets.isNotEmpty) return;

    // 3. Start Sync
    state = SyncStatusState.syncing('Restoring your data from cloud...');

    try {
      final repository = ref.read(syncRepositoryProvider);
      await repository.syncFromCloud();
      state = SyncStatusState.completed();
    } catch (e) {
      state = SyncStatusState.error(
        'Failed to restore data. Please check your connection.',
      );
    }
  }

  void reset() {
    state = SyncStatusState.idle();
  }
}

final syncStatusProvider =
    NotifierProvider<SyncStatusNotifier, SyncStatusState>(
      SyncStatusNotifier.new,
    );
