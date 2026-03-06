import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uangku/core/services/monitoring_service.dart';

/// Service responsible for managing data synchronization with Firebase Firestore.
///
/// Under the hood, this uses Firestore's built-in offline persistence.
/// Writes when offline are queued locally and automatically pushed to the server
/// when the device regains internet connectivity.
class SyncService {
  final FirebaseFirestore _firestore;
  final MonitoringService _monitoring;

  SyncService(this._firestore, this._monitoring);

  /// Helper to get a user's collection reference
  CollectionReference<Map<String, dynamic>> _userCollection(
    String userId,
    String collection,
  ) {
    return _firestore.collection('users').doc(userId).collection(collection);
  }

  // --- Transactions ---

  /// Upserts a transaction to Firestore.
  /// Needs a user ID, the transaction's string ID, and its mapped payload.
  Future<void> upsertTransaction(
    String userId,
    String transactionId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _userCollection(
        userId,
        'transactions',
      ).doc(transactionId).set(data, SetOptions(merge: true));
    } catch (e, st) {
      _monitoring.logError('SyncService.upsertTransaction failure', e, st);
    }
  }

  /// Deletes a transaction from Firestore.
  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      await _userCollection(userId, 'transactions').doc(transactionId).delete();
    } catch (e, st) {
      _monitoring.logError('SyncService.deleteTransaction failure', e, st);
    }
  }

  // --- Categories ---

  /// Upserts a category to Firestore.
  Future<void> upsertCategory(
    String userId,
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _userCollection(
        userId,
        'categories',
      ).doc(categoryId).set(data, SetOptions(merge: true));
    } catch (e, st) {
      _monitoring.logError('SyncService.upsertCategory failure', e, st);
    }
  }

  /// Deletes a category from Firestore.
  Future<void> deleteCategory(String userId, String categoryId) async {
    try {
      await _userCollection(userId, 'categories').doc(categoryId).delete();
    } catch (e, st) {
      _monitoring.logError('SyncService.deleteCategory failure', e, st);
    }
  }

  // --- Wallets ---

  /// Upserts a wallet to Firestore.
  Future<void> upsertWallet(
    String userId,
    String walletId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _userCollection(
        userId,
        'wallets',
      ).doc(walletId).set(data, SetOptions(merge: true));
    } catch (e, st) {
      _monitoring.logError('SyncService.upsertWallet failure', e, st);
    }
  }

  /// Deletes a wallet from Firestore.
  Future<void> deleteWallet(String userId, String walletId) async {
    try {
      await _userCollection(userId, 'wallets').doc(walletId).delete();
    } catch (e, st) {
      _monitoring.logError('SyncService.deleteWallet failure', e, st);
    }
  }
}
