import 'package:uangku/data/database.dart';

/// Repository interface (contract) for Wallet data access.
///
/// All wallet I/O operations must go through this abstraction.
/// This enables:
/// - Unit testing with mock implementations
/// - Swapping storage backends without changing business logic
/// - Enforcing the Dependency Inversion Principle
///
/// Uses Drift-generated [Wallet] and [WalletsCompanion] types. While this
/// couples the interface to Drift types, it avoids redundant mapping layers
/// for an app whose sole storage mechanism is SQLite via Drift.
abstract class WalletRepository {
  /// Returns a reactive stream of all wallets, ordered by creation date.
  Stream<List<Wallet>> watchAllWallets();

  /// Inserts a new wallet and returns the generated ID.
  Future<int> createWallet(WalletsCompanion wallet);

  /// Updates an existing wallet. Returns true if any row was affected.
  Future<bool> updateWallet(WalletsCompanion wallet);

  /// Deletes a wallet by its [id]. Returns true if any row was affected.
  Future<bool> deleteWallet(int id);

  /// Returns a single wallet by [id], or null if not found.
  Future<Wallet?> getWalletById(int id);
}
