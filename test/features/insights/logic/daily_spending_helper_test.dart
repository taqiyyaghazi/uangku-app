import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/data/models/daily_spending.dart';
import 'package:uangku/features/insights/logic/daily_spending_helper.dart';

void main() {
  group('DailySpendingHelper Tests', () {
    test('fillDailySpendingGaps should fill missing days in a month', () {
      final month = DateTime(2024, 3); // March has 31 days
      final records = [
        DailySpending(date: DateTime(2024, 3, 1), totalAmount: 100.0),
        DailySpending(date: DateTime(2024, 3, 5), totalAmount: 50.0),
      ];

      final result = DailySpendingHelper.fillDailySpendingGaps(records, month);

      expect(result.length, 31);
      expect(result[0].totalAmount, 100.0);
      expect(result[1].totalAmount, 0.0);
      expect(result[2].totalAmount, 0.0);
      expect(result[3].totalAmount, 0.0);
      expect(result[4].totalAmount, 50.0);
      expect(result.last.date, DateTime(2024, 3, 31));
    });

    test('fillDailySpendingGaps should handle February in a leap year', () {
      final month = DateTime(2024, 2); // 2024 is a leap year (29 days)
      final records = <DailySpending>[];

      final result = DailySpendingHelper.fillDailySpendingGaps(records, month);

      expect(result.length, 29);
      expect(result.last.date, DateTime(2024, 2, 29));
    });

    test('fillDailySpendingGaps should handle February in a non-leap year', () {
      final month = DateTime(2023, 2); // 2023 is not a leap year (28 days)
      final records = <DailySpending>[];

      final result = DailySpendingHelper.fillDailySpendingGaps(records, month);

      expect(result.length, 28);
      expect(result.last.date, DateTime(2023, 2, 28));
    });
  });
}
