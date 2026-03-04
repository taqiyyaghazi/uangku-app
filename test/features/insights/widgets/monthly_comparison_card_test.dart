import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/data/models/monthly_comparison.dart';
import 'package:uangku/data/models/monthly_summary.dart';
import 'package:uangku/features/insights/widgets/monthly_comparison_card.dart';

void main() {
  testWidgets('MonthlyComparisonCard displays data correctly', (tester) async {
    const comparison = MonthlyComparison(
      current: MonthlySummary(totalIncome: 12000, totalExpenses: 8000),
      previous: MonthlySummary(totalIncome: 10000, totalExpenses: 10000),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MonthlyComparisonCard(comparison: comparison)),
      ),
    );

    expect(find.text('Perbandingan Bulan Ini'), findsOneWidget);
    expect(find.text('Pendapatan'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);

    // Check amounts (CurrencyFormatter formatted)
    // 12000 -> Rp 12.000 (standard format)
    expect(find.textContaining('12.000'), findsOneWidget);
    expect(find.textContaining('8.000'), findsOneWidget);

    // Check deltas
    // Income: (12-10)/10 = 20%
    // Expense: (8-10)/10 = -20%
    expect(find.textContaining('20.0%'), findsNWidgets(2));

    // Check savings rate
    // Current: (12-8)/12 = 33.3%
    expect(find.text('33.3%'), findsOneWidget);
  });
}
