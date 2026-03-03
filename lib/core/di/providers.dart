import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/core/constants/app_constants.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/daos/drift_investment_repository.dart';
import 'package:uangku/data/daos/drift_wallet_repository.dart';
import 'package:uangku/data/daos/drift_transaction_repository.dart';
import 'package:uangku/data/repositories/investment_repository.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/features/dashboard/logic/budget_service.dart';
import 'package:uangku/features/dashboard/logic/settings_providers.dart';
import 'package:uangku/features/dashboard/models/budget_state.dart';

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

/// Provides the [WalletRepository] backed by Drift.
///
/// Override this in tests with a mock implementation.
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftWalletRepository(db);
});

/// Provides a reactive stream of all wallets.
final walletsProvider = StreamProvider<List<Wallet>>((ref) {
  final repo = ref.watch(walletRepositoryProvider);
  return repo.watchAllWallets();
});

/// Provides the [TransactionRepository] backed by Drift.
///
/// Override this in tests with a mock implementation.
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftTransactionRepository(db);
});

/// Provides the [InvestmentRepository] backed by Drift.
///
/// Override this in tests with a mock implementation.
final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftInvestmentRepository(db);
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
      transactions: txns,
    );
  });
});

/// Provides a reactive stream of the 10 most recent transactions
/// across all wallets, ordered by date descending.
///
/// Automatically updates when transactions are added, edited, or deleted.
final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.watchRecentTransactions(10);
});
