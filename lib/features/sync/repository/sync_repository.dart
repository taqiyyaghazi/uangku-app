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
}
