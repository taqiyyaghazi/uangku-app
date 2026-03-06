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
  Future<void> syncBudget(int categoryId, String periodMonth);
  Future<void> deleteBudget(int categoryId, String periodMonth);
  Future<void> syncInvestment(int snapshotId, {InvestmentSnapshot? snapshot});
  Future<void> deleteInvestment(int snapshotId);
  Future<void> syncFromCloud();
  Future<void> pushAllToCloud();

  Future<void> syncSetting(String key);
  Future<void> deleteSetting(String key);
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
  Future<void> syncBudget(int categoryId, String periodMonth) async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      final budget =
          await (_db.select(_db.budgets)..where(
                (t) =>
                    t.categoryId.equals(categoryId) &
                    t.periodMonth.equals(periodMonth),
              ))
              .getSingleOrNull();

      if (budget != null) {
        final budgetId = '${categoryId}_$periodMonth';
        await _sync.upsertBudget(
          uid,
          budgetId,
          FirestoreMapper.budgetToFirestore(budget),
        );
      }
    } catch (e, st) {
      _monitoring.logError('Failed to sync budget $categoryId', e, st, {
        'categoryId': categoryId,
        'periodMonth': periodMonth,
      });
    }
  }

  @override
  Future<void> deleteBudget(int categoryId, String periodMonth) async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      final budgetId = '${categoryId}_$periodMonth';
      await _sync.deleteBudget(uid, budgetId);
    } catch (e, st) {
      _monitoring.logError('Failed to delete budget $categoryId', e, st, {
        'categoryId': categoryId,
        'periodMonth': periodMonth,
      });
    }
  }

  @override
  Future<void> syncInvestment(
    int snapshotId, {
    InvestmentSnapshot? snapshot,
  }) async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      final item =
          snapshot ??
          await (_db.select(
            _db.investmentSnapshots,
          )..where((t) => t.id.equals(snapshotId))).getSingleOrNull();

      if (item != null) {
        await _sync.upsertInvestment(
          uid,
          item.id.toString(),
          FirestoreMapper.investmentToFirestore(item),
        );
      }
    } catch (e, st) {
      _monitoring.logError('Failed to sync investment $snapshotId', e, st, {
        'snapshotId': snapshotId,
      });
    }
  }

  @override
  Future<void> deleteInvestment(int snapshotId) async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      await _sync.deleteInvestment(uid, snapshotId.toString());
    } catch (e, st) {
      _monitoring.logError('Failed to delete investment $snapshotId', e, st, {
        'snapshotId': snapshotId,
      });
    }
  }

  @override
  Future<void> syncSetting(String key) async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      final setting = await (_db.select(
        _db.appSettings,
      )..where((t) => t.key.equals(key))).getSingleOrNull();

      if (setting != null) {
        await _sync.upsertSetting(
          uid,
          key,
          FirestoreMapper.settingToFirestore(setting),
        );
      }
    } catch (e, st) {
      _monitoring.logError('Failed to sync setting $key', e, st, {'key': key});
    }
  }

  @override
  Future<void> deleteSetting(String key) async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      await _sync.deleteSetting(uid, key);
    } catch (e, st) {
      _monitoring.logError('Failed to delete setting $key', e, st, {
        'key': key,
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
      final budgetsData = await _sync.fetchAllBudgets(uid);
      final investmentsData = await _sync.fetchAllInvestments(uid);
      final settingsData = await _sync.fetchAllSettings(uid);

      if (categoriesData.isEmpty &&
          walletsData.isEmpty &&
          transactionsData.isEmpty &&
          budgetsData.isEmpty &&
          investmentsData.isEmpty &&
          settingsData.isEmpty) {
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
      final budgets = budgetsData.map(FirestoreMapper.budgetFromValue).toList();
      final investments = investmentsData
          .map(FirestoreMapper.investmentFromFirestore)
          .toList();
      final settings = settingsData
          .map(FirestoreMapper.settingFromFirestore)
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
        // Then Budgets
        b.insertAll(_db.budgets, budgets, mode: InsertMode.insertOrReplace);
        // Then Investments
        b.insertAll(
          _db.investmentSnapshots,
          investments,
          mode: InsertMode.insertOrReplace,
        );
        // settings last
        b.insertAll(
          _db.appSettings,
          settings,
          mode: InsertMode.insertOrReplace,
        );
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
        'budgets': budgets.length,
        'investments': investments.length,
        'settings': settings.length,
      });
    } catch (e, st) {
      _monitoring.logError('Critical failure during cloud restoration', e, st);
      rethrow;
    }
  }

  @override
  Future<void> pushAllToCloud() async {
    final uid = _getUserId();
    if (uid == null) return;

    try {
      _monitoring.logInfo('Starting push of all local data to cloud...');

      // 1. Fetch all local data
      final categories = await _db.select(_db.categories).get();
      final wallets = await _db.select(_db.wallets).get();
      final transactions = await _db.select(_db.transactions).get();
      final budgets = await _db.select(_db.budgets).get();
      final investments = await _db.select(_db.investmentSnapshots).get();
      final settings = await _db.select(_db.appSettings).get();

      // 2. Push to Firestore
      // Categories
      for (final item in categories) {
        await _sync.upsertCategory(
          uid,
          item.id.toString(),
          FirestoreMapper.categoryToFirestore(item),
        );
      }
      // Wallets
      for (final item in wallets) {
        await _sync.upsertWallet(
          uid,
          item.id.toString(),
          FirestoreMapper.walletToFirestore(item),
        );
      }
      // Transactions
      for (final item in transactions) {
        await _sync.upsertTransaction(
          uid,
          item.id.toString(),
          FirestoreMapper.transactionToFirestore(item),
        );
      }
      // Budgets
      for (final item in budgets) {
        final budgetId = '${item.categoryId}_${item.periodMonth}';
        await _sync.upsertBudget(
          uid,
          budgetId,
          FirestoreMapper.budgetToFirestore(item),
        );
      }
      // Investments
      for (final item in investments) {
        await _sync.upsertInvestment(
          uid,
          item.id.toString(),
          FirestoreMapper.investmentToFirestore(item),
        );
      }
      // Settings
      for (final item in settings) {
        await _sync.upsertSetting(
          uid,
          item.key,
          FirestoreMapper.settingToFirestore(item),
        );
      }

      _monitoring.logInfo('Successfully pushed all local data to cloud', {
        'categories': categories.length,
        'wallets': wallets.length,
        'transactions': transactions.length,
        'budgets': budgets.length,
        'investments': investments.length,
        'settings': settings.length,
      });
    } catch (e, st) {
      _monitoring.logError('Failure during cloud push', e, st);
    }
  }
}
