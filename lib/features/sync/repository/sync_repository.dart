import 'package:drift/drift.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/features/sync/services/sync_service.dart';
import 'package:uangku/features/sync/utils/firestore_mapper.dart';
import 'package:uangku/core/services/monitoring_service.dart';

/// Abstract contract for synchronization capabilities.
///
/// This allows data repositories to trigger sync operations without
/// depending on specific implementations (like Firestore).
abstract class SyncRepository {
  Future<void> syncTransaction(int transactionId);
  Future<void> deleteTransaction(int transactionId);
  Future<void> syncCategory(int categoryId);
  Future<void> deleteCategory(int categoryId);
  Future<void> syncWallet(int walletId);
  Future<void> deleteWallet(int walletId);
  Future<void> syncFromCloud();
}

/// Firestore-backed implementation of [SyncRepository].
class FirestoreSyncRepository implements SyncRepository {
  final AppDatabase _db;
  final SyncService _sync;
  final MonitoringService _monitoring;
  final String? Function() _getUserId;

  FirestoreSyncRepository(
    this._db,
    this._sync,
    this._monitoring,
    this._getUserId,
  );

  @override
  Future<void> syncTransaction(int transactionId) async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      final tx = await (_db.select(
        _db.transactions,
      )..where((t) => t.id.equals(transactionId))).getSingleOrNull();

      if (tx != null) {
        await _sync.upsertTransaction(
          uid,
          tx.id.toString(),
          FirestoreMapper.transactionToFirestore(tx),
        );
      }
    } catch (e, st) {
      _monitoring.logError('Failed to sync transaction $transactionId', e, st, {
        'transactionId': transactionId,
      });
    }
  }

  @override
  Future<void> deleteTransaction(int transactionId) async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      await _sync.deleteTransaction(uid, transactionId.toString());
    } catch (e, st) {
      _monitoring.logError(
        'Failed to delete transaction $transactionId',
        e,
        st,
        {'transactionId': transactionId},
      );
    }
  }

  @override
  Future<void> syncCategory(int categoryId) async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      final category = await (_db.select(
        _db.categories,
      )..where((c) => c.id.equals(categoryId))).getSingleOrNull();

      if (category != null) {
        await _sync.upsertCategory(
          uid,
          category.id.toString(),
          FirestoreMapper.categoryToFirestore(category),
        );
      }
    } catch (e, st) {
      _monitoring.logError('Failed to sync category $categoryId', e, st, {
        'categoryId': categoryId,
      });
    }
  }

  @override
  Future<void> deleteCategory(int categoryId) async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      await _sync.deleteCategory(uid, categoryId.toString());
    } catch (e, st) {
      _monitoring.logError('Failed to delete category $categoryId', e, st, {
        'categoryId': categoryId,
      });
    }
  }

  @override
  Future<void> syncWallet(int walletId) async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      final wallet = await (_db.select(
        _db.wallets,
      )..where((w) => w.id.equals(walletId))).getSingleOrNull();

      if (wallet != null) {
        await _sync.upsertWallet(
          uid,
          wallet.id.toString(),
          FirestoreMapper.walletToFirestore(wallet),
        );
      }
    } catch (e, st) {
      _monitoring.logError('Failed to sync wallet $walletId', e, st, {
        'walletId': walletId,
      });
    }
  }

  @override
  Future<void> deleteWallet(int walletId) async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      await _sync.deleteWallet(uid, walletId.toString());
    } catch (e, st) {
      _monitoring.logError('Failed to delete wallet $walletId', e, st, {
        'walletId': walletId,
      });
    }
  }

  @override
  Future<void> syncFromCloud() async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      // 1. Fetch
      final categoriesData = await _sync.fetchAllCategories(uid);
      final walletsData = await _sync.fetchAllWallets(uid);
      final transactionsData = await _sync.fetchAllTransactions(uid);

      if (categoriesData.isEmpty &&
          walletsData.isEmpty &&
          transactionsData.isEmpty) {
        return;
      }

      // 2. Map
      final categories = categoriesData
          .map(FirestoreMapper.categoryFromFirestore)
          .toList();
      final wallets = walletsData
          .map(FirestoreMapper.walletFromFirestore)
          .toList();
      final transactions = transactionsData
          .map(FirestoreMapper.transactionFromFirestore)
          .toList();

      // 3. Sequential Batch Insert
      await _db.batch((b) {
        // Categories first
        b.insertAll(
          _db.categories,
          categories,
          mode: InsertMode.insertOrReplace,
        );
        // Then Wallets
        b.insertAll(_db.wallets, wallets, mode: InsertMode.insertOrReplace);
        // Finally Transactions
        b.insertAll(
          _db.transactions,
          transactions,
          mode: InsertMode.insertOrReplace,
        );
      });

      _monitoring.logInfo('Successfully restored data from cloud', {
        'transactions': transactions.length,
        'categories': categories.length,
        'wallets': wallets.length,
      });
    } catch (e, st) {
      _monitoring.logError('Critical failure during cloud restoration', e, st);
      rethrow;
    }
  }
}
