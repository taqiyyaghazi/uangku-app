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
      rethrow;
    }
  }

  /// Deletes a transaction from Firestore.
  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      await _userCollection(userId, 'transactions').doc(transactionId).delete();
    } catch (e, st) {
      _monitoring.logError('SyncService.deleteTransaction failure', e, st);
      rethrow;
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
      rethrow;
    }
  }

  /// Deletes a category from Firestore.
  Future<void> deleteCategory(String userId, String categoryId) async {
    try {
      await _userCollection(userId, 'categories').doc(categoryId).delete();
    } catch (e, st) {
      _monitoring.logError('SyncService.deleteCategory failure', e, st);
      rethrow;
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
      rethrow;
    }
  }

  /// Deletes a wallet from Firestore.
  Future<void> deleteWallet(String userId, String walletId) async {
    try {
      await _userCollection(userId, 'wallets').doc(walletId).delete();
    } catch (e, st) {
      _monitoring.logError('SyncService.deleteWallet failure', e, st);
      rethrow;
    }
  }

  // --- Budgets ---

  /// Upserts a budget to Firestore.
  Future<void> upsertBudget(
    String userId,
    String budgetId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _userCollection(
        userId,
        'budgets',
      ).doc(budgetId).set(data, SetOptions(merge: true));
    } catch (e, st) {
      _monitoring.logError('SyncService.upsertBudget failure', e, st);
      rethrow;
    }
  }

  /// Deletes a budget from Firestore.
  Future<void> deleteBudget(String userId, String budgetId) async {
    try {
      await _userCollection(userId, 'budgets').doc(budgetId).delete();
    } catch (e, st) {
      _monitoring.logError('SyncService.deleteBudget failure', e, st);
      rethrow;
    }
  }

  // --- Investments ---

  /// Upserts an investment snapshot to Firestore.
  Future<void> upsertInvestment(
    String userId,
    String snapshotId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _userCollection(
        userId,
        'investments',
      ).doc(snapshotId).set(data, SetOptions(merge: true));
    } catch (e, st) {
      _monitoring.logError('SyncService.upsertInvestment failure', e, st);
      rethrow;
    }
  }

  /// Deletes an investment snapshot from Firestore.
  Future<void> deleteInvestment(String userId, String snapshotId) async {
    try {
      await _userCollection(userId, 'investments').doc(snapshotId).delete();
    } catch (e, st) {
      _monitoring.logError('SyncService.deleteInvestment failure', e, st);
      rethrow;
    }
  }

  // --- Bulk Fetching (Restoration) ---

  /// Fetches all transactions for a user from Firestore.
  Future<List<Map<String, dynamic>>> fetchAllTransactions(String userId) async {
    try {
      final snapshot = await _userCollection(userId, 'transactions').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e, st) {
      _monitoring.logError('SyncService.fetchAllTransactions failure', e, st);
      rethrow;
    }
  }

  /// Fetches all categories for a user from Firestore.
  Future<List<Map<String, dynamic>>> fetchAllCategories(String userId) async {
    try {
      final snapshot = await _userCollection(userId, 'categories').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e, st) {
      _monitoring.logError('SyncService.fetchAllCategories failure', e, st);
      rethrow;
    }
  }

  /// Fetches all wallets for a user from Firestore.
  Future<List<Map<String, dynamic>>> fetchAllWallets(String userId) async {
    try {
      final snapshot = await _userCollection(userId, 'wallets').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e, st) {
      _monitoring.logError('SyncService.fetchAllWallets failure', e, st);
      rethrow;
    }
  }

  /// Fetches all budgets for a user from Firestore.
  Future<List<Map<String, dynamic>>> fetchAllBudgets(String userId) async {
    try {
      final snapshot = await _userCollection(userId, 'budgets').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e, st) {
      _monitoring.logError('SyncService.fetchAllBudgets failure', e, st);
      rethrow;
    }
  }

  /// Fetches all investment snapshots for a user from Firestore.
  Future<List<Map<String, dynamic>>> fetchAllInvestments(String userId) async {
    try {
      final snapshot = await _userCollection(userId, 'investments').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e, st) {
      _monitoring.logError('SyncService.fetchAllInvestments failure', e, st);
      rethrow;
    }
  }

  /// Upserts a setting to Firestore.
  Future<void> upsertSetting(
    String userId,
    String key,
    Map<String, dynamic> data,
  ) async {
    try {
      await _userCollection(
        userId,
        'settings',
      ).doc(key).set(data, SetOptions(merge: true));
    } catch (e, st) {
      _monitoring.logError('SyncService.upsertSetting failure', e, st);
      rethrow;
    }
  }

  /// Deletes a setting from Firestore.
  Future<void> deleteSetting(String userId, String key) async {
    try {
      await _userCollection(userId, 'settings').doc(key).delete();
    } catch (e, st) {
      _monitoring.logError('SyncService.deleteSetting failure', e, st);
      rethrow;
    }
  }

  /// Fetches all settings for a user from Firestore.
  Future<List<Map<String, dynamic>>> fetchAllSettings(String userId) async {
    try {
      final snapshot = await _userCollection(userId, 'settings').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e, st) {
      _monitoring.logError('SyncService.fetchAllSettings failure', e, st);
      rethrow;
    }
  }
}
