import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uangku/core/constants/app_constants.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/daos/drift_investment_repository.dart';
import 'package:uangku/data/daos/drift_wallet_repository.dart';
import 'package:uangku/data/daos/drift_transaction_repository.dart';
import 'package:uangku/data/repositories/category_repository.dart';
import 'package:uangku/data/repositories/investment_repository.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/data/repositories/category_repository_impl.dart';
import 'package:uangku/data/repositories/budget_repository.dart';
import 'package:uangku/data/daos/drift_budget_repository.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/auth/state/auth_provider.dart';
import 'package:uangku/features/dashboard/logic/budget_service.dart';
import 'package:uangku/features/dashboard/logic/settings_providers.dart';
import 'package:uangku/features/dashboard/models/budget_state.dart';
import 'package:uangku/features/sync/repository/sync_repository.dart';
import 'package:uangku/features/sync/services/sync_service.dart';

/// Provides the singleton [AppDatabase] instance across the app.
///
/// This is the single source of truth for the local database connection.
/// Override this provider in tests using `ProviderScope.overrides`.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();

  // Ensure the database is closed when the provider is disposed.
  ref.onDispose(() => db.close());

  return db;
});

/// Provides the [FirebaseFirestore] instance.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provides the [SyncService] for Firestore operations.
final syncServiceProvider = Provider<SyncService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final monitoring = ref.watch(monitoringServiceProvider);
  return SyncService(firestore, monitoring);
});

/// Provides the [SyncRepository] to coordinate local and cloud data.
final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncService = ref.watch(syncServiceProvider);
  final monitoring = ref.watch(monitoringServiceProvider);
  return FirestoreSyncRepository(
    db,
    syncService,
    monitoring,
    () => ref.read(authStateProvider).value?.id,
  );
});

/// Provides the [WalletRepository] backed by Drift + Sync.
///
/// Override this in tests with a mock implementation.
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  final monitoring = ref.watch(monitoringServiceProvider);
  return DriftWalletRepository(db, monitoring, syncRepo);
});

/// Provides a reactive stream of all wallets.
final walletsProvider = StreamProvider<List<Wallet>>((ref) {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.watchAllWallets();
});

/// Provides the [TransactionRepository] backed by Drift + Sync.
///
/// Override this in tests with a mock implementation.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  final monitoring = ref.watch(monitoringServiceProvider);
  return DriftTransactionRepository(db, monitoring, syncRepo);
});

/// Provides the [CategoryRepository] backed by Drift + Sync.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  final monitoring = ref.watch(monitoringServiceProvider);
  return CategoryRepositoryImpl(db, monitoring, syncRepo);
});

/// Provides a reactive stream of categories filtered by type.
final categoriesByTypeProvider =
    StreamProvider.family<List<Category>, TransactionType>((ref, type) {
      final repo = ref.watch(categoryRepositoryProvider);
      return repo.watchCategoriesByType(type);
    });

/// Provides the [BudgetRepository] backed by Drift + Sync.
final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  final monitoring = ref.watch(monitoringServiceProvider);
  return DriftBudgetRepository(db, monitoring, syncRepo);
});

/// Provides the [InvestmentRepository] backed by Drift + Sync.
///
/// Override this in tests with a mock implementation.
final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  final monitoring = ref.watch(monitoringServiceProvider);
  return DriftInvestmentRepository(db, monitoring, syncRepo);
});

/// Provides a reactive stream of snapshots for a specific investment wallet.
///
/// Usage: `ref.watch(investmentSnapshotsProvider(walletId))`
final investmentSnapshotsProvider =
    StreamProvider.family<List<InvestmentSnapshot>, int>((ref, walletId) {
      final repo = ref.watch(investmentRepositoryProvider);
      return repo.watchSnapshotsByWallet(walletId);
    });

/// Provides a reactive [BudgetState] computed from the current month's
/// transactions.
///
/// Automatically recalculates whenever a new transaction is recorded
/// (the Drift `watchTransactionsByDateRange` stream emits).
final dailyBreathProvider = StreamProvider<BudgetState>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  final monthlyBudgetAsync = ref.watch(monthlyBudgetProvider);

  // Default to 5.0M if the user hasn't configured a monthly budget yet.
  final configuredBudget = monthlyBudgetAsync.value ?? 0.0;
  final effectiveBudget = configuredBudget > 0
      ? configuredBudget
      : AppConstants.defaultMonthlyBudget;

  // Watch all transactions in the current calendar month.
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month);
  final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  return repo.watchTransactionsByDateRange(monthStart, monthEnd).map((txns) {
    return BudgetService.calculate(
      monthlyLimit: effectiveBudget,
      transactions: txns.map((t) => t.transaction).toList(),
    );
  });
});

/// Provides a reactive stream of the 10 most recent transactions
/// across all wallets, ordered by date descending.
///
/// Automatically updates when transactions are added, edited, or deleted.
final recentTransactionsProvider =
    StreamProvider<List<TransactionWithCategory>>((ref) {
      final repo = ref.watch(transactionRepositoryProvider);
      return repo.watchRecentTransactions(10);
    });

/// State provider to hold the currently selected wallet ID for filtering.
/// null means "All Wallets".
class SelectedWalletFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setFilter(int? walletId) {
    state = walletId;
  }
}

final selectedWalletFilterProvider =
    NotifierProvider<SelectedWalletFilterNotifier, int?>(
      () => SelectedWalletFilterNotifier(),
    );

/// Provides a reactive stream of all transactions
/// across all wallets, ordered by date descending.
/// Respects the [selectedWalletFilterProvider] if set.
final allTransactionsProvider = StreamProvider<List<TransactionWithCategory>>((
  ref,
) {
  final repo = ref.watch(transactionRepositoryProvider);
  final selectedWalletId = ref.watch(selectedWalletFilterProvider);
  return repo.watchAllTransactions(walletId: selectedWalletId);
});
