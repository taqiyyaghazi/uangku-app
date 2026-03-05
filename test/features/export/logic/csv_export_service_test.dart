import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/transaction_with_details.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/export/logic/csv_export_service.dart';

void main() {
  group('CsvExportService.generateCsv', () {
    test('returns only header row for empty list', () {
      final csv = CsvExportService.generateCsv([]);

      expect(csv, 'Date,Amount,Category,Wallet,Type,Notes');
    });

    test('formats expense transaction correctly', () {
      final transactions = [
        TransactionWithDetails(
          transaction: Transaction(
            id: 1,
            walletId: 1,
            amount: 50000,
            type: TransactionType.expense,
            categoryId: 1,
            note: 'Lunch',
            date: DateTime(2026, 3, 5),
            createdAt: DateTime(2026, 3, 5),
          ),
          categoryName: 'Food',
          walletName: 'Cash',
        ),
      ];

      final csv = CsvExportService.generateCsv(transactions);
      final lines = csv.split('\r\n');

      expect(lines.length, 2);
      expect(lines[0], 'Date,Amount,Category,Wallet,Type,Notes');
      expect(lines[1], '2026-03-05,50000.0,Food,Cash,Expense,Lunch');
    });

    test('formats income transaction correctly', () {
      final transactions = [
        TransactionWithDetails(
          transaction: Transaction(
            id: 2,
            walletId: 1,
            amount: 5000000,
            type: TransactionType.income,
            categoryId: 2,
            note: 'Salary',
            date: DateTime(2026, 3, 1),
            createdAt: DateTime(2026, 3, 1),
          ),
          categoryName: 'Salary',
          walletName: 'Bank BCA',
        ),
      ];

      final csv = CsvExportService.generateCsv(transactions);
      final lines = csv.split('\r\n');

      expect(lines[1], '2026-03-01,5000000.0,Salary,Bank BCA,Income,Salary');
    });

    test('formats transfer with source → destination wallet', () {
      final transactions = [
        TransactionWithDetails(
          transaction: Transaction(
            id: 3,
            walletId: 1,
            toWalletId: 2,
            amount: 100000,
            type: TransactionType.transfer,
            note: 'Withdraw',
            date: DateTime(2026, 3, 10),
            createdAt: DateTime(2026, 3, 10),
          ),
          categoryName: null,
          walletName: 'Bank BCA',
          toWalletName: 'Cash',
        ),
      ];

      final csv = CsvExportService.generateCsv(transactions);
      final lines = csv.split('\r\n');

      expect(
        lines[1],
        '2026-03-10,100000.0,Transfer,Bank BCA → Cash,Transfer,Withdraw',
      );
    });

    test('handles null category for non-transfer as Uncategorized', () {
      final transactions = [
        TransactionWithDetails(
          transaction: Transaction(
            id: 4,
            walletId: 1,
            amount: 10000,
            type: TransactionType.expense,
            note: '',
            date: DateTime(2026, 1, 15),
            createdAt: DateTime(2026, 1, 15),
          ),
          categoryName: null,
          walletName: 'Cash',
        ),
      ];

      final csv = CsvExportService.generateCsv(transactions);
      final lines = csv.split('\r\n');

      expect(lines[1], '2026-01-15,10000.0,Uncategorized,Cash,Expense,');
    });

    test('escapes CSV special characters in notes', () {
      final transactions = [
        TransactionWithDetails(
          transaction: Transaction(
            id: 5,
            walletId: 1,
            amount: 25000,
            type: TransactionType.expense,
            categoryId: 1,
            note: 'Lunch, dinner "and" snacks',
            date: DateTime(2026, 2, 20),
            createdAt: DateTime(2026, 2, 20),
          ),
          categoryName: 'Food',
          walletName: 'Cash',
        ),
      ];

      final csv = CsvExportService.generateCsv(transactions);
      final lines = csv.split('\r\n');

      // CSV library should quote the field containing commas/quotes.
      expect(lines[1], contains('"'));
      expect(lines[1], contains('Lunch'));
    });

    test('handles multiple transactions correctly', () {
      final transactions = [
        TransactionWithDetails(
          transaction: Transaction(
            id: 1,
            walletId: 1,
            amount: 50000,
            type: TransactionType.expense,
            categoryId: 1,
            note: 'Lunch',
            date: DateTime(2026, 3, 5),
            createdAt: DateTime(2026, 3, 5),
          ),
          categoryName: 'Food',
          walletName: 'Cash',
        ),
        TransactionWithDetails(
          transaction: Transaction(
            id: 2,
            walletId: 1,
            amount: 5000000,
            type: TransactionType.income,
            categoryId: 2,
            note: 'Salary',
            date: DateTime(2026, 3, 1),
            createdAt: DateTime(2026, 3, 1),
          ),
          categoryName: 'Salary',
          walletName: 'Bank BCA',
        ),
      ];

      final csv = CsvExportService.generateCsv(transactions);
      final lines = csv.split('\r\n');

      // Header + 2 data rows.
      expect(lines.length, 3);
    });
  });

  group('CsvExportService.generateFileName', () {
    test('returns filename with current date', () {
      final fileName = CsvExportService.generateFileName();

      expect(fileName, startsWith('Uangku_Export_'));
      expect(fileName, endsWith('.csv'));
      // Should be 8 digits for the date part (yyyyMMdd).
      final datePart = fileName
          .replaceFirst('Uangku_Export_', '')
          .replaceFirst('.csv', '');
      expect(datePart.length, 8);
      expect(int.tryParse(datePart), isNotNull);
    });
  });
}
