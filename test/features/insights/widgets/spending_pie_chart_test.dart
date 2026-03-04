import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/data/models/category_spending.dart';
import 'package:uangku/features/insights/widgets/spending_pie_chart.dart';

void main() {
  group('SpendingPieChart Widget Tests', () {
    testWidgets('renders empty state message when data is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpendingPieChart(spendingData: [], totalSpending: 0),
          ),
        ),
      );

      expect(find.text('Belum ada data untuk periode ini.'), findsOneWidget);
      expect(find.byIcon(Icons.pie_chart_outline), findsOneWidget);
    });

    testWidgets('renders categories and amounts when data is provided', (
      tester,
    ) async {
      final spendingData = [
        CategorySpending(
          categoryName: 'Food',
          totalAmount: 150000,
          colorCode: '#FF5733',
        ),
        CategorySpending(
          categoryName: 'Transport',
          totalAmount: 50000,
          colorCode: '#33FF57',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpendingPieChart(
              spendingData: spendingData,
              totalSpending: 200000,
            ),
          ),
        ),
      );

      // Verify category names
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);

      // Verify amounts (formatted)
      expect(find.text('Rp 150000'), findsOneWidget);
      expect(find.text('Rp 50000'), findsOneWidget);

      // Verify percentages
      expect(find.text('75.0%'), findsOneWidget);
      expect(find.text('25.0%'), findsOneWidget);
    });
  });
}
