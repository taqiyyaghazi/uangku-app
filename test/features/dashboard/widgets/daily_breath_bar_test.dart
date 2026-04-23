import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uangku/core/di/providers.dart';

import 'package:uangku/features/dashboard/models/budget_state.dart';
import 'package:uangku/features/dashboard/widgets/daily_breath_bar.dart';

void main() {
  final testTheme = ThemeData(
    useMaterial3: true,
    splashFactory: InkSplash.splashFactory,
  );

  late SharedPreferences prefs;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({'is_hidden': false});
  });

  setUp(() async {
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildTestWidget(BudgetState state) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp(
        theme: testTheme,
        home: Scaffold(body: DailyBreathBar(budgetState: state)),
      ),
    );
  }

  group('DailyBreathBar', () {
    testWidgets('displays "Daily Breath" title', (tester) async {
      const state = BudgetState(
        monthlyLimit: 3000000,
        totalSpentThisMonth: 0,
        spentToday: 0,
        dailyAllowance: 100000,
        remainingDays: 30,
        remainingBudget: 3000000,
        progressRatio: 0,
        isOverspent: false,
      );

      await tester.pumpWidget(buildTestWidget(state));
      expect(find.text('Daily Breath'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('shows remaining days', (tester) async {
      const state = BudgetState(
        monthlyLimit: 3000000,
        totalSpentThisMonth: 0,
        spentToday: 0,
        dailyAllowance: 100000,
        remainingDays: 15,
        remainingBudget: 3000000,
        progressRatio: 0,
        isOverspent: false,
      );

      await tester.pumpWidget(buildTestWidget(state));
      expect(find.text('15 days left'), findsOneWidget);
    });

    testWidgets('shows formatted spent and limit amounts', (tester) async {
      const state = BudgetState(
        monthlyLimit: 3000000,
        totalSpentThisMonth: 50000,
        spentToday: 50000,
        dailyAllowance: 100000,
        remainingDays: 30,
        remainingBudget: 2950000,
        progressRatio: 0.5,
        isOverspent: false,
      );

      await tester.pumpWidget(buildTestWidget(state));
      await tester.pumpAndSettle();

      expect(find.textContaining('Spent:'), findsOneWidget);
      expect(find.textContaining('Limit:'), findsOneWidget);
    });

    testWidgets('shows correction message when overspent', (tester) async {
      const state = BudgetState(
        monthlyLimit: 3000000,
        totalSpentThisMonth: 200000,
        spentToday: 200000,
        dailyAllowance: 100000,
        remainingDays: 30,
        remainingBudget: 2800000,
        progressRatio: 2.0,
        isOverspent: true,
        correctionMessage:
            "Overspent Rp 100.000 today. Tomorrow's budget: Rp 90.000.",
      );

      await tester.pumpWidget(buildTestWidget(state));
      await tester.pumpAndSettle();

      expect(find.textContaining('Overspent'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('does not show correction when within budget', (tester) async {
      const state = BudgetState(
        monthlyLimit: 3000000,
        totalSpentThisMonth: 50000,
        spentToday: 50000,
        dailyAllowance: 100000,
        remainingDays: 30,
        remainingBudget: 2950000,
        progressRatio: 0.5,
        isOverspent: false,
      );

      await tester.pumpWidget(buildTestWidget(state));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
    });
  });
}
