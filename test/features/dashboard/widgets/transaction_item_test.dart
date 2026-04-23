import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uangku/core/di/providers.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/dashboard/widgets/transaction_item.dart';

import 'package:intl/intl.dart';

void main() {
  final now = DateTime.now();
  late SharedPreferences prefs;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({'is_hidden': false});
  });

  setUp(() async {
    prefs = await SharedPreferences.getInstance();
  });

  TransactionWithCategory makeTransaction({
    int id = 1,
    int walletId = 1,
    double amount = 50000,
    TransactionType type = TransactionType.expense,
    String categoryName = 'Food',
    String note = '',
    DateTime? date,
  }) {
    return TransactionWithCategory(
      transaction: Transaction(
        id: id,
        walletId: walletId,
        categoryId: 1,
        amount: amount,
        type: type,
        date: date ?? now,
        note: note,
        createdAt: now,
        updatedAt: now,
      ),
      category: Category(
        id: 1,
        name: categoryName,
        iconCode: 'fastfood',
        type: type,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Widget buildTestWidget(
    TransactionWithCategory tx, {
    String walletName = 'Bank BCA',
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TransactionItem(transaction: tx, walletName: walletName),
        ),
      ),
    );
  }

  group('TransactionItem', () {
    testWidgets('displays category name', (tester) async {
      await tester.pumpWidget(buildTestWidget(makeTransaction()));
      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('displays wallet name in subtitle', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(makeTransaction(), walletName: 'Cash'),
      );
      expect(find.textContaining('Cash'), findsOneWidget);
    });

    testWidgets('displays relative time in subtitle', (tester) async {
      await tester.pumpWidget(buildTestWidget(makeTransaction()));
      // "Today, HH:mm" or similar should appear in subtitle.
      final expectedTime = DateFormat('HH:mm').format(now);
      expect(find.textContaining(expectedTime), findsOneWidget);
    });

    testWidgets('displays formatted expense amount with minus prefix', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(makeTransaction(amount: 50000)));
      expect(find.text('-Rp 50.000'), findsOneWidget);
    });

    testWidgets('displays formatted income amount with plus prefix', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          makeTransaction(
            amount: 1000000,
            type: TransactionType.income,
            categoryName: 'Salary',
          ),
        ),
      );
      expect(find.text('+Rp 1.000.000'), findsOneWidget);
    });

    testWidgets('displays category icon via CircleAvatar', (tester) async {
      await tester.pumpWidget(buildTestWidget(makeTransaction()));
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TransactionItem(
                transaction: makeTransaction(),
                walletName: 'Bank',
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TransactionItem));
      expect(tapped, isTrue);
    });
  });
}
