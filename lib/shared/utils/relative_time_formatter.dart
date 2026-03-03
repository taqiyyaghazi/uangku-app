import 'package:intl/intl.dart';

/// Formats a [DateTime] as a human-friendly relative time label.
///
/// Examples: "Today, 14:30", "Yesterday, 09:15", "28 Feb".
///
/// Pure utility — injectable [now] parameter for deterministic testing.
class RelativeTimeFormatter {
  RelativeTimeFormatter._();

  static final _timeFormat = DateFormat('HH:mm');
  static final _dateFormat = DateFormat('d MMM');

  /// Formats [date] relative to [now].
  ///
  /// - Same calendar day → "Today, HH:mm"
  /// - Previous calendar day → "Yesterday, HH:mm"
  /// - Older → "d MMM" (e.g. "28 Feb")
  static String format(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final today = DateTime(reference.year, reference.month, reference.day);
    final dateDay = DateTime(date.year, date.month, date.day);

    final difference = today.difference(dateDay).inDays;

    if (difference == 0) {
      return 'Today, ${_timeFormat.format(date)}';
    } else if (difference == 1) {
      return 'Yesterday, ${_timeFormat.format(date)}';
    } else {
      return _dateFormat.format(date);
    }
  }
}
