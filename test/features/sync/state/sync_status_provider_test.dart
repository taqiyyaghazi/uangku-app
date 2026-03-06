import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/settings_repository.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/auth/models/user_profile.dart';
import 'package:uangku/features/auth/repository/auth_repository.dart';
import 'package:uangku/features/auth/state/auth_provider.dart';
import 'package:uangku/features/dashboard/logic/settings_providers.dart';
import 'package:uangku/features/sync/repository/sync_repository.dart';
import 'package:uangku/features/sync/services/sync_service.dart';
import 'package:uangku/features/sync/state/sync_status_provider.dart';

import 'sync_status_provider_test.mocks.dart';

@GenerateMocks([
  SyncRepository,
  WalletRepository,
  AuthRepository,
  MonitoringService,
  SettingsRepository,
  AppDatabase,
  SyncService,
])
void main() {
  late MockSyncRepository mockSyncRepo;
  late MockWalletRepository mockWalletRepo;
  late MockAuthRepository mockAuthRepo;
  late MockMonitoringService mockMonitoring;
  late MockSettingsRepository mockSettingsRepo;

  setUp(() {
    mockSyncRepo = MockSyncRepository();
    mockWalletRepo = MockWalletRepository();
    mockAuthRepo = MockAuthRepository();
    mockMonitoring = MockMonitoringService();
    mockSettingsRepo = MockSettingsRepository();
  });

  ProviderContainer createContainer({UserProfile? user}) {
    final container = ProviderContainer(
      overrides: [
        syncRepositoryProvider.overrideWithValue(mockSyncRepo),
        walletRepositoryProvider.overrideWithValue(mockWalletRepo),
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        authStateProvider.overrideWithValue(AsyncValue.data(user)),
        monitoringServiceProvider.overrideWithValue(mockMonitoring),
        settingsRepositoryProvider.overrideWithValue(mockSettingsRepo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('SyncStatusNotifier', () {
    test('initial state triggers restoration check', () async {
      when(mockWalletRepo.watchAllWallets()).thenAnswer(
        (_) => Stream.value([
          Wallet(
            id: 1,
            name: 'W',
            balance: 0,
            type: WalletType.cash,
            colorHex: '#0',
            icon: 'i',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ]),
      );
      when(
        mockSettingsRepo.isInitialPushCompleted(),
      ).thenAnswer((_) async => true);

      final container = createContainer();
      // build() is now idle
      final status = container.read(syncStatusProvider);
      expect(status.status, SyncStatus.idle);

      await Future.delayed(Duration.zero);
      expect(container.read(syncStatusProvider).status, SyncStatus.idle);
    });

    test('restoreDataIfNeeded skips if user is null', () async {
      final container = createContainer(user: null);
      container.read(syncStatusProvider); // trigger build
      await Future.delayed(Duration.zero);

      verifyNever(mockSyncRepo.syncFromCloud());
    });

    test(
      'restoreDataIfNeeded skips if local wallets exist and pushed',
      () async {
        final wallet = Wallet(
          id: 1,
          name: 'C',
          balance: 100,
          type: WalletType.cash,
          colorHex: '#0',
          icon: 'w',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          mockWalletRepo.watchAllWallets(),
        ).thenAnswer((_) => Stream.value([wallet]));
        when(
          mockSettingsRepo.isInitialPushCompleted(),
        ).thenAnswer((_) async => true);

        final container = createContainer(
          user: UserProfile(id: '123', email: 'test@test.com'),
        );

        container.read(syncStatusProvider);
        await Future.delayed(Duration.zero);

        verifyNever(mockSyncRepo.syncFromCloud());
        verifyNever(mockSyncRepo.pushAllToCloud());
      },
    );

    test(
      'restoreDataIfNeeded triggers push if local wallets exist and push not completed',
      () async {
        final wallet = Wallet(
          id: 1,
          name: 'C',
          balance: 100,
          type: WalletType.cash,
          colorHex: '#0',
          icon: 'w',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          mockWalletRepo.watchAllWallets(),
        ).thenAnswer((_) => Stream.value([wallet]));
        when(
          mockSettingsRepo.isInitialPushCompleted(),
        ).thenAnswer((_) async => false);
        when(mockSyncRepo.pushAllToCloud()).thenAnswer((_) async {});
        when(
          mockSettingsRepo.markInitialPushCompleted(),
        ).thenAnswer((_) async {});

        final container = createContainer(
          user: UserProfile(id: '123', email: 'test@test.com'),
        );

        // Wait for auto-trigger microtask
        container.read(syncStatusProvider);
        await Future.delayed(Duration.zero);

        verify(mockSyncRepo.pushAllToCloud()).called(1);
        verify(mockSettingsRepo.markInitialPushCompleted()).called(1);
        expect(container.read(syncStatusProvider).status, SyncStatus.idle);
      },
    );

    test('auto-triggers sync and completes correctly', () async {
      final syncCompleter = Completer<void>();
      when(
        mockWalletRepo.watchAllWallets(),
      ).thenAnswer((_) => Stream.value([]));
      when(
        mockSyncRepo.syncFromCloud(),
      ).thenAnswer((_) => syncCompleter.future);

      final container = createContainer(
        user: UserProfile(id: '123', email: 'test@test.com'),
      );

      // Trigger auto-sync
      container.read(syncStatusProvider);

      await untilCalled(mockSyncRepo.syncFromCloud());
      expect(container.read(syncStatusProvider).status, SyncStatus.syncing);

      syncCompleter.complete();
      await Future.delayed(Duration.zero);

      expect(container.read(syncStatusProvider).status, SyncStatus.completed);
    });

    test('handles errors during sync', () async {
      final syncCompleter = Completer<void>();
      when(
        mockWalletRepo.watchAllWallets(),
      ).thenAnswer((_) => Stream.value([]));
      when(
        mockSyncRepo.syncFromCloud(),
      ).thenAnswer((_) => syncCompleter.future);

      final container = createContainer(
        user: UserProfile(id: '123', email: 'test@test.com'),
      );

      // Trigger auto-sync
      container.read(syncStatusProvider);

      await untilCalled(mockSyncRepo.syncFromCloud());

      syncCompleter.completeError(Exception('Sync failed'));
      await Future.delayed(Duration.zero);

      expect(container.read(syncStatusProvider).status, SyncStatus.error);
    });
  });
}
