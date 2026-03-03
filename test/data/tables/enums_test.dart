import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/data/tables/transactions_table.dart';

void main() {
  group('WalletType enum', () {
    test('should have exactly 3 values', () {
      expect(WalletType.values.length, 3);
    });

    test('should contain cash, bank, and investment', () {
      expect(WalletType.values, contains(WalletType.cash));
      expect(WalletType.values, contains(WalletType.bank));
      expect(WalletType.values, contains(WalletType.investment));
    });

    test('should convert to and from name string', () {
      for (final type in WalletType.values) {
        final name = type.name;
        final parsed = WalletType.values.byName(name);
        expect(parsed, equals(type));
      }
    });
  });

  group('TransactionType enum', () {
    test('should have exactly 3 values', () {
      expect(TransactionType.values.length, 3);
    });

    test('should contain income, expense, and transfer', () {
      expect(TransactionType.values, contains(TransactionType.income));
      expect(TransactionType.values, contains(TransactionType.expense));
      expect(TransactionType.values, contains(TransactionType.transfer));
    });

    test('should convert to and from name string', () {
      for (final type in TransactionType.values) {
        final name = type.name;
        final parsed = TransactionType.values.byName(name);
        expect(parsed, equals(type));
      }
    });
  });
}
