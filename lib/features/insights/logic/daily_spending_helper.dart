import 'package:uangku/data/models/daily_spending.dart';

/// Pure business logic for Daily Spending Trend.
///
/// This provides gap-filling and data transformation independent of SQLite/Drift.
class DailySpendingHelper {
  DailySpendingHelper._();

  /// Fills gaps in spending records to ensure every day of the month is represented.
  ///
  /// [records] is the partial list of spending from the database.
  /// [month] is the target month for which to generate the full list.
  ///
  /// Returns a full list of [DailySpending] objects, one for each day of the month.
  static List<DailySpending> fillDailySpendingGaps(
    List<DailySpending> records,
    DateTime month,
  ) {
    final resultMap = {
      for (final record in records)
        _toDateString(record.date): record.totalAmount,
    };

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final date = DateTime(month.year, month.month, day);
      final dateString = _toDateString(date);

      final amount = resultMap[dateString] ?? 0.0;
      return DailySpending(date: date, totalAmount: amount);
    });
  }

  static String _toDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
