import 'package:drift/drift.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/features/sync/services/sync_service.dart';
import 'package:uangku/features/sync/utils/firestore_mapper.dart';
import 'dart:developer' as developer;

/// Coordinates fetching data from the local Drift database
/// and pushing the mapped JSON to the [SyncService].
class SyncRepository {
  final AppDatabase _db;
  final SyncService _sync;
  final String? Function() _getUserId;

  SyncRepository(this._db, this._sync, this._getUserId);

  // --- Transactions ---

  /// Reads a transaction from the local DB and upserts it to Firestore.
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
      developer.log(
        'Failed to sync transaction $transactionId',
        name: 'SyncRepository',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Removes a transaction from Firestore.
  Future<void> deleteTransaction(int transactionId) async {
    final uid = _getUserId();
    if (uid == null) return;

    await _sync.deleteTransaction(uid, transactionId.toString());
  }

  // --- Categories ---

  /// Reads a category from the local DB and upserts it to Firestore.
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
      developer.log(
        'Failed to sync category $categoryId',
        name: 'SyncRepository',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Removes a category from Firestore.
  Future<void> deleteCategory(int categoryId) async {
    final uid = _getUserId();
    if (uid == null) return;

    await _sync.deleteCategory(uid, categoryId.toString());
  }

  // --- Wallets ---

  /// Reads a wallet from the local DB and upserts it to Firestore.
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
      developer.log(
        'Failed to sync wallet $walletId',
        name: 'SyncRepository',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Removes a wallet from Firestore.
  Future<void> deleteWallet(int walletId) async {
    final uid = _getUserId();
    if (uid == null) return;

    await _sync.deleteWallet(uid, walletId.toString());
  }

  // --- Restoration Logic ---

  /// Fetches everything from Firestore and populates the local DB.
  /// Uses sequential batch inserts to satisfy Foreign Key constraints.
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

      developer.log(
        'Successfully restored ${transactions.length} transactions from cloud.',
        name: 'SyncRepository',
      );
    } catch (e, st) {
      developer.log(
        'Critical failure during cloud restoration',
        name: 'SyncRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }
}
