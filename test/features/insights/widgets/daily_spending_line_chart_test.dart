import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/data/models/daily_spending.dart';
import 'package:uangku/features/insights/widgets/daily_spending_line_chart.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  group('DailySpendingLineChart Widget Tests', () {
    testWidgets('renders nothing when empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DailySpendingLineChart(spendingData: [])),
        ),
      );

      expect(find.text('Tren Pengeluaran Harian'), findsNothing);
    });

    testWidgets('renders chart and title when data provided', (tester) async {
      final mockData = [
        DailySpending(date: DateTime(2025, 3, 1), totalAmount: 100000),
        DailySpending(date: DateTime(2025, 3, 2), totalAmount: 200000),
      ];

      // Set a larger size for the chart to render properly
      await tester.binding.setSurfaceSize(const Size(800, 600));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DailySpendingLineChart(spendingData: mockData)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tren Pengeluaran Harian'), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('formats Y-axis labels correctly', (tester) async {
      final mockData = [
        DailySpending(date: DateTime(2025, 3, 1), totalAmount: 2000000),
      ];

      await tester.binding.setSurfaceSize(const Size(800, 600));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DailySpendingLineChart(spendingData: mockData)),
        ),
      );
      await tester.pumpAndSettle();

      // maxY = 2M * 1.2 = 2.4M. Interval = 0.6M.
      // Labels: 0, 0.6M, 1.2M, 1.8M, 2.4M.
      // My formatter: 600000 -> 600k (actually it should be 600k)
      // 1200000 -> 1.2M
      expect(find.text('Rp 1,2M'), findsOneWidget);
      expect(find.text('Rp 1,8M'), findsOneWidget);
    });
  });
}
