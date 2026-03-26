import 'package:uangku/data/database.dart';

/// Filters a list of [Wallet]s by name using case-insensitive matching.
///
/// Returns the full list when [query] is empty or whitespace-only.
/// This is a pure function with no I/O — fully testable and deterministic.
///
/// Client-side filtering is sufficient for typical wallet counts (<100).
List<Wallet> filterWallets(List<Wallet> wallets, String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return wallets;

  final lowerQuery = trimmed.toLowerCase();
  return wallets
      .where((wallet) => wallet.name.toLowerCase().contains(lowerQuery))
      .toList();
}
