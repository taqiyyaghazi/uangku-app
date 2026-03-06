import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/auth/models/user_profile.dart';
import 'package:uangku/features/auth/repository/auth_repository.dart';
import 'package:uangku/features/auth/state/auth_provider.dart';
import 'package:uangku/features/sync/repository/sync_repository.dart';
import 'package:uangku/features/sync/state/sync_status_provider.dart';

import 'sync_status_provider_test.mocks.dart';

@GenerateMocks([SyncRepository, WalletRepository, AuthRepository])
void main() {
  late MockSyncRepository mockSyncRepo;
  late MockWalletRepository mockWalletRepo;
  late MockAuthRepository mockAuthRepo;

  setUp(() {
    mockSyncRepo = MockSyncRepository();
    mockWalletRepo = MockWalletRepository();
    mockAuthRepo = MockAuthRepository();
  });

  ProviderContainer createContainer({UserProfile? user}) {
    final container = ProviderContainer(
      overrides: [
        syncRepositoryProvider.overrideWithValue(mockSyncRepo),
        walletRepositoryProvider.overrideWithValue(mockWalletRepo),
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        authStateProvider.overrideWithValue(AsyncValue.data(user)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('SyncStatusNotifier', () {
    test('initial state is idle', () {
      final container = createContainer();
      final status = container.read(syncStatusProvider);
      expect(status.status, SyncStatus.idle);
    });

    test('restoreDataIfNeeded skips if user is null', () async {
      final container = createContainer(user: null);
      await container.read(syncStatusProvider.notifier).restoreDataIfNeeded();

      verifyNever(mockSyncRepo.syncFromCloud());
      expect(container.read(syncStatusProvider).status, SyncStatus.idle);
    });

    test('restoreDataIfNeeded skips if local wallets exist', () async {
      final wallet = Wallet(
        id: 1,
        name: 'Cash',
        balance: 100.0,
        type: WalletType.cash,
        colorHex: '#000000',
        icon: 'wallet',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(
        mockWalletRepo.watchAllWallets(),
      ).thenAnswer((_) => Stream.value([wallet]));

      final container = createContainer(
        user: UserProfile(id: '123', email: 'test@test.com'),
      );

      await container.read(syncStatusProvider.notifier).restoreDataIfNeeded();

      verifyNever(mockSyncRepo.syncFromCloud());
    });

    test(
      'restoreDataIfNeeded performs sync if local wallets are empty',
      () async {
        when(
          mockWalletRepo.watchAllWallets(),
        ).thenAnswer((_) => Stream.value([]));
        when(mockSyncRepo.syncFromCloud()).thenAnswer((_) async {});

        final container = createContainer(
          user: UserProfile(id: '123', email: 'test@test.com'),
        );

        final notifier = container.read(syncStatusProvider.notifier);
        await notifier.restoreDataIfNeeded();

        verify(mockSyncRepo.syncFromCloud()).called(1);
        expect(container.read(syncStatusProvider).status, SyncStatus.completed);
      },
    );

    test('handles errors during sync', () async {
      when(
        mockWalletRepo.watchAllWallets(),
      ).thenAnswer((_) => Stream.value([]));
      when(mockSyncRepo.syncFromCloud()).thenThrow(Exception('Sync failed'));

      final container = createContainer(
        user: UserProfile(id: '123', email: 'test@test.com'),
      );

      await container.read(syncStatusProvider.notifier).restoreDataIfNeeded();

      expect(container.read(syncStatusProvider).status, SyncStatus.error);
    });
  });
}
