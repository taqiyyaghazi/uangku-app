import 'package:intl/intl.dart';

/// Formats monetary values for display in the Indonesian Rupiah locale.
///
/// This is a pure utility — no I/O, no state, fully testable.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _formatterWithDecimals = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );

  /// Formats [amount] as Indonesian Rupiah (e.g. "Rp 1.250.000").
  ///
  /// Shows decimals only when [amount] has a fractional part.
  static String format(double amount) {
    if (amount == amount.truncateToDouble()) {
      return _formatter.format(amount);
    }
    return _formatterWithDecimals.format(amount);
  }

  /// Formats [amount] showing a sign prefix for positive values.
  ///
  /// Useful for displaying income (+) or expense (−) amounts.
  static String formatSigned(double amount) {
    final formatted = format(amount.abs());
    if (amount > 0) return '+$formatted';
    if (amount < 0) return '-$formatted';
    return formatted;
  }
}
