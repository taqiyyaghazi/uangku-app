import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/transaction/logic/transaction_grouping_logic.dart';

void main() {
  group('TransactionGroupingLogic', () {
    final t1 = TransactionWithCategory(
      transaction: Transaction(
        id: 1,
        walletId: 1,
        categoryId: 1,
        type: TransactionType.expense,
        amount: 50000,
        date: DateTime(2026, 3, 10), // March 2026
        note: 'Lunch at KFC',
        createdAt: DateTime.now(),
      ),
      category: Category(
        id: 1,
        name: 'food',
        iconCode: 'fastfood',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
      ),
    );
    final t2 = TransactionWithCategory(
      transaction: Transaction(
        id: 2,
        walletId: 1,
        categoryId: 2,
        type: TransactionType.expense,
        amount: 20000,
        date: DateTime(2026, 3, 5), // March 2026
        note: 'Gojek',
        createdAt: DateTime.now(),
      ),
      category: Category(
        id: 2,
        name: 'transport',
        iconCode: 'directions_car',
        type: TransactionType.expense,
        createdAt: DateTime.now(),
      ),
    );
    final t3 = TransactionWithCategory(
      transaction: Transaction(
        id: 3,
        walletId: 1,
        categoryId: 3,
        type: TransactionType.income,
        amount: 5000000,
        date: DateTime(2026, 2, 25), // February 2026
        note: 'February Salary',
        createdAt: DateTime.now(),
      ),
      category: Category(
        id: 3,
        name: 'salary',
        iconCode: 'attach_money',
        type: TransactionType.income,
        createdAt: DateTime.now(),
      ),
    );

    final transactions = [t1, t2, t3];

    group('groupByMonth', () {
      test('groups transactions by Month Year strings', () {
        final grouped = TransactionGroupingLogic.groupByMonth(transactions);

        expect(grouped.keys.length, 2);
        expect(grouped.keys.elementAt(0), 'March 2026');
        expect(grouped.keys.elementAt(1), 'February 2026');

        expect(grouped['March 2026']!.length, 2);
        expect(grouped['February 2026']!.length, 1);
        expect(grouped['March 2026']!.first.transaction.id, 1);
      });

      test('handles empty list', () {
        final grouped = TransactionGroupingLogic.groupByMonth([]);
        expect(grouped.isEmpty, true);
      });
    });

    group('filterBySearchQuery', () {
      test('returns all when query is empty', () {
        final filtered = TransactionGroupingLogic.filterBySearchQuery(
          transactions,
          '',
        );
        expect(filtered.length, 3);
      });

      test('filters by note (case insensitive)', () {
        final filtered = TransactionGroupingLogic.filterBySearchQuery(
          transactions,
          'LUNCH',
        );
        expect(filtered.length, 1);
        expect(filtered.first.transaction.id, 1);
      });

      test('filters by category id', () {
        final filtered = TransactionGroupingLogic.filterBySearchQuery(
          transactions,
          'transport',
        );
        expect(filtered.length, 1);
        expect(filtered.first.transaction.id, 2);
      });

      test('returns empty list if no match', () {
        final filtered = TransactionGroupingLogic.filterBySearchQuery(
          transactions,
          'Starbucks',
        );
        expect(filtered.isEmpty, true);
      });
    });
  });
}
