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
  /// If [isHidden] is true, returns a masked string.
  static String format(double amount, {bool isHidden = false}) {
    if (isHidden) return "Rp ••••••";
    
    if (amount == amount.truncateToDouble()) {
      return _formatter.format(amount);
    }
    return _formatterWithDecimals.format(amount);
  }

  /// Formats [amount] showing a sign prefix for positive values.
  ///
  /// Useful for displaying income (+) or expense (−) amounts.
  /// If [isHidden] is true, returns a masked string without signs.
  static String formatSigned(double amount, {bool isHidden = false}) {
    if (isHidden) return "Rp ••••••";
    
    final formatted = format(amount.abs());
    if (amount > 0) return '+$formatted';
    if (amount < 0) return '-$formatted';
    return formatted;
  }

  /// Formats [amount] as an abbreviated Indonesian Rupiah (e.g. "Rp 1,2M", "Rp 500k").
  ///
  /// Useful for chart labels where space is limited.
  /// If [isHidden] is true, returns a masked string.
  static String formatCompact(double amount, {bool isHidden = false}) {
    if (isHidden) return "Rp •••";
    
    if (amount.abs() >= 1000000) {
      final value = amount / 1000000;
      final s = value.toStringAsFixed(1);
      final formattedValue = s.endsWith('.0')
          ? s.substring(0, s.length - 2)
          : s;
      return 'Rp ${formattedValue.replaceAll('.', ',')}M';
    } else if (amount.abs() >= 1000) {
      final value = amount / 1000;
      final s = value.toStringAsFixed(1);
      final formattedValue = s.endsWith('.0')
          ? s.substring(0, s.length - 2)
          : s;
      return 'Rp ${formattedValue.replaceAll('.', ',')}k';
    }
    return format(amount);
  }
}
