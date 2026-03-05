import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:uangku/data/models/transaction_with_details.dart';
import 'package:uangku/data/tables/transactions_table.dart';

/// Pure service for generating CSV strings from transaction data.
///
/// This class contains ONLY pure functions — no I/O, no side effects.
/// File writing and sharing are handled externally.
class CsvExportService {
  /// The CSV column headers for the export file.
  static const List<String> headers = [
    'Date',
    'Amount',
    'Category',
    'Wallet',
    'Type',
    'Notes',
  ];

  /// Generates a CSV string from a list of [TransactionWithDetails].
  ///
  /// - Dates are formatted as `yyyy-MM-dd` for Excel compatibility.
  /// - Amounts are raw numbers (no currency symbols) for spreadsheet math.
  /// - Category is the human-readable name (or "Transfer" for transfers).
  /// - Wallet shows source wallet, and for transfers appends " → `<`dest>".
  /// - Type is one of: Income, Expense, Transfer.
  ///
  /// Returns a properly-escaped CSV string including the header row.
  static String generateCsv(List<TransactionWithDetails> transactions) {
    final dateFormatter = DateFormat('yyyy-MM-dd');

    final rows = <List<dynamic>>[
      headers,
      ...transactions.map((t) => _transactionToRow(t, dateFormatter)),
    ];

    return const CsvEncoder().convert(rows);
  }

  /// Generates the dynamic file name for the export.
  ///
  /// Format: `Uangku_Export_YYYYMMDD.csv`
  static String generateFileName() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    return 'Uangku_Export_$dateStr.csv';
  }

  /// Converts a single [TransactionWithDetails] into a CSV row.
  static List<dynamic> _transactionToRow(
    TransactionWithDetails detail,
    DateFormat dateFormatter,
  ) {
    final tx = detail.transaction;

    // Format the date for Excel compatibility.
    final dateStr = dateFormatter.format(tx.date);

    // Raw numeric amount — no currency symbol.
    final amount = tx.amount;

    // Category: use name for income/expense, "Transfer" for transfers.
    final category = tx.type == TransactionType.transfer
        ? 'Transfer'
        : (detail.categoryName ?? 'Uncategorized');

    // Wallet: for transfers, show "Source → Destination".
    final wallet =
        tx.type == TransactionType.transfer && detail.toWalletName != null
        ? '${detail.walletName} → ${detail.toWalletName}'
        : detail.walletName;

    // Capitalize the type.
    final type = switch (tx.type) {
      TransactionType.income => 'Income',
      TransactionType.expense => 'Expense',
      TransactionType.transfer => 'Transfer',
    };

    final notes = tx.note;

    return [dateStr, amount, category, wallet, type, notes];
  }
}
