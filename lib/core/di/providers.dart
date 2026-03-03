import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/daos/drift_wallet_repository.dart';
import 'package:uangku/data/daos/drift_transaction_repository.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';

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
