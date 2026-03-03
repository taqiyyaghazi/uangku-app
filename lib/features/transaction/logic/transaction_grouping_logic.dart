import 'package:intl/intl.dart';
import 'package:uangku/data/database.dart';

/// Pure logic for grouping and filtering transactions.
///
/// Follows the Testability-First architectural pattern.
class TransactionGroupingLogic {
  TransactionGroupingLogic._();

  /// Groups a list of [transactions] by month and year.
  /// Resulting map keys are formatted like "March 2026".
  /// Assumes [transactions] are already sorted chronologically (e.g. desc).
  static Map<String, List<Transaction>> groupByMonth(
    List<Transaction> transactions,
  ) {
    final Map<String, List<Transaction>> groups = {};
    // Use Intl to format the date as "Month Year" (e.g. "March 2026")
    final formatter = DateFormat('MMMM yyyy');

    for (final t in transactions) {
      final key = formatter.format(t.date);
      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(t);
    }

    return groups;
  }

  /// Filters a list of [transactions] by a [searchQuery].
  /// Matches against the transaction note and the category name (case-insensitive).
  static List<Transaction> filterBySearchQuery(
    List<Transaction> transactions,
    String searchQuery,
  ) {
    if (searchQuery.trim().isEmpty) {
      return transactions;
    }

    final query = searchQuery.toLowerCase().trim();
    return transactions.where((t) {
      final noteMatch = t.note.toLowerCase().contains(query);
      final categoryMatch = t.category.toLowerCase().contains(query);
      return noteMatch || categoryMatch;
    }).toList();
  }
}
