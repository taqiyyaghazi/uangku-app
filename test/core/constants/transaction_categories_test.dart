import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/core/constants/transaction_categories.dart';

void main() {
  group('TransactionCategories', () {
    test('expense categories are non-empty', () {
      expect(TransactionCategories.expense, isNotEmpty);
    });

    test('income categories are non-empty', () {
      expect(TransactionCategories.income, isNotEmpty);
    });

    test('transfer categories contain Transfer', () {
      expect(TransactionCategories.transfer, contains('Transfer'));
    });

    test('all categories have no duplicates', () {
      expect(
        TransactionCategories.expense.toSet().length,
        TransactionCategories.expense.length,
      );
      expect(
        TransactionCategories.income.toSet().length,
        TransactionCategories.income.length,
      );
    });

    test('expense categories include common items', () {
      expect(TransactionCategories.expense, contains('Food'));
      expect(TransactionCategories.expense, contains('Transport'));
      expect(TransactionCategories.expense, contains('Bills'));
    });

    test('income categories include Salary', () {
      expect(TransactionCategories.income, contains('Salary'));
    });
  });
}
