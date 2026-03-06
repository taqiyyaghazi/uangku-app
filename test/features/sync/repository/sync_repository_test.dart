import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/sync/repository/sync_repository.dart';
import 'package:uangku/features/sync/services/sync_service.dart';

import 'sync_repository_test.mocks.dart';

@GenerateMocks([SyncService, MonitoringService])
void main() {
  late AppDatabase db;
  late MockSyncService mockSync;
  late MockMonitoringService mockMonitoring;
  late FirestoreSyncRepository syncRepository;
  String? userId = 'user-123';

  setUp(() {
    userId = 'user-123';
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mockSync = MockSyncService();
    mockMonitoring = MockMonitoringService();
    syncRepository = FirestoreSyncRepository(
      db,
      mockSync,
      mockMonitoring,
      () => userId,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('SyncRepository', () {
    test('syncWallet uploads wallet data to Firestore', () async {
      // 1. Create a wallet in local DB
      final walletId = await db
          .into(db.wallets)
          .insert(
            WalletsCompanion.insert(
              name: 'Main Wallet',
              balance: const Value(100.0),
              type: WalletType.cash,
            ),
          );

      // 2. Mock SyncService response
      when(mockSync.upsertWallet(any, any, any)).thenAnswer((_) async {});

      // 3. Trigger sync
      await syncRepository.syncWallet(walletId);

      // 4. Verify SyncService was called with correct data
      verify(
        mockSync.upsertWallet(
          'user-123',
          walletId.toString(),
          argThat(containsPair('name', 'Main Wallet')),
        ),
      ).called(1);
    });

    test('syncTransaction uploads transaction data to Firestore', () async {
      // 1. Setup - Transaction needs a wallet
      final walletId = await db
          .into(db.wallets)
          .insert(
            WalletsCompanion.insert(
              name: 'Wallet',
              balance: const Value(100.0),
              type: WalletType.cash,
            ),
          );

      final txId = await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              walletId: walletId,
              amount: 50.0,
              type: TransactionType.expense,
              date: DateTime.now(),
              note: const Value('Gift'),
            ),
          );

      // 2. Mock
      when(mockSync.upsertTransaction(any, any, any)).thenAnswer((_) async {});

      // 3. Sync
      await syncRepository.syncTransaction(txId);

      // 4. Verify
      verify(
        mockSync.upsertTransaction(
          'user-123',
          txId.toString(),
          argThat(containsPair('note', 'Gift')),
        ),
      ).called(1);
    });

    test('deleteTransaction calls SyncService for deletion', () async {
      // 1. Mock
      when(mockSync.deleteTransaction(any, any)).thenAnswer((_) async {});

      // 2. Delete
      await syncRepository.deleteTransaction(99);

      // 3. Verify
      verify(mockSync.deleteTransaction('user-123', '99')).called(1);
    });

    test('sync does nothing if user is not logged in', () async {
      userId = null;

      await syncRepository.syncWallet(1);

      verifyNever(mockSync.upsertWallet(any, any, any));
    });

    test('syncFromCloud fetches all and performs batch insert', () async {
      // 1. Mock responses
      final now = DateTime.now();
      final timestamp = firestore.Timestamp.fromDate(now);

      final catData = {
        'id': 1,
        'name': 'Food',
        'type': 'expense',
        'iconCode': 'icon',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      };
      final walletData = {
        'id': 1,
        'name': 'Cash',
        'balance': 100.0,
        'type': 'cash',
        'colorHex': '#000000',
        'icon': 'icon',
        'createdAt': timestamp,
        'updatedAt': timestamp,
      };
      final txData = {
        'id': 1,
        'walletId': 1,
        'amount': 50.0,
        'type': 'expense',
        'categoryId': 1,
        'note': 'Coffee',
        'date': timestamp,
        'createdAt': timestamp,
        'updatedAt': timestamp,
      };

      when(
        mockSync.fetchAllCategories('user-123'),
      ).thenAnswer((_) async => [catData]);
      when(
        mockSync.fetchAllWallets('user-123'),
      ).thenAnswer((_) async => [walletData]);
      when(
        mockSync.fetchAllTransactions('user-123'),
      ).thenAnswer((_) async => [txData]);
      when(mockSync.fetchAllBudgets('user-123')).thenAnswer((_) async => []);
      when(
        mockSync.fetchAllInvestments('user-123'),
      ).thenAnswer((_) async => []);

      // 2. Clear local DB categories
      await db.delete(db.categories).go();

      // 3. Sync
      await syncRepository.syncFromCloud();

      // 3. Verify local DB state
      final cats = await db.select(db.categories).get();
      final wallets = await db.select(db.wallets).get();
      final txs = await db.select(db.transactions).get();

      expect(cats.length, 1);
      expect(cats.first.name, 'Food');
      expect(wallets.length, 1);
      expect(wallets.first.name, 'Cash');
      expect(txs.length, 1);
      expect(txs.first.note, 'Coffee');
    });
  });
}
