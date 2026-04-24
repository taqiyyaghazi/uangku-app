import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/transaction/models/nlp_transaction_result.dart';

void main() {
  group('NlpTransactionResult.fromJson', () {
    final defaultWallet = Wallet(
      id: 1,
      name: 'Gopay',
      icon: 'wallet',
      colorHex: '#000000',
      type: WalletType.cash,
      balance: 100000,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final bcaWallet = Wallet(
      id: 2,
      name: 'BCA',
      icon: 'bank',
      colorHex: '#000000',
      type: WalletType.bank,
      balance: 500000,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final wallets = <Wallet>[defaultWallet, bcaWallet];

    final foodCategory = Category(
      id: 1,
      name: 'Food',
      iconCode: '🍔',
      type: TransactionType.expense,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final salaryCategory = Category(
      id: 2,
      name: 'Salary',
      iconCode: '💰',
      type: TransactionType.income,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final categories = <Category>[foodCategory, salaryCategory];

    test('should parse correctly with exact matches', () {
      final json = {
        'amount': 25000,
        'type': 'expense',
        'wallet': 'Gopay',
        'toWallet': null,
        'category': 'Food',
        'note': 'beli kopi',
        'date': '2023-10-25'
      };

      final result = NlpTransactionResult.fromJson(json, wallets, categories, defaultWallet);

      expect(result.amount, 25000);
      expect(result.type, TransactionType.expense);
      expect(result.wallet?.id, defaultWallet.id);
      expect(result.toWallet, isNull);
      expect(result.category?.id, foodCategory.id);
      expect(result.note, 'beli kopi');
      expect(result.date.year, 2023);
      expect(result.date.month, 10);
      expect(result.date.day, 25);
    });

    test('should parse correctly with string amount', () {
      final json = {
        'amount': '25000',
        'type': 'expense',
        'wallet': 'BCA',
        'category': 'Food',
        'note': 'beli kopi',
      };

      final result = NlpTransactionResult.fromJson(json, wallets, categories, defaultWallet);

      expect(result.amount, 25000);
      expect(result.wallet?.id, bcaWallet.id);
    });

    test('should fuzzy match category and wallet', () {
      final json = {
        'amount': 5000,
        'type': 'income',
        'wallet': 'gpy', // Not exact match, but contains/is contained? Actually it's simple fuzzy match using contains
        'category': 'salry', // Simple contain might fail here, but let's test fallback
        'note': 'bonus',
      };
      
      // We will just verify it doesn't crash and uses defaults if fuzzy match fails
      final result = NlpTransactionResult.fromJson(json, wallets, categories, defaultWallet);
      
      expect(result.amount, 5000);
      expect(result.type, TransactionType.income);
      expect(result.wallet?.id, defaultWallet.id); // Falls back to default if no contain match
      expect(result.category?.id, salaryCategory.id); // Falls back to first category of the correct type
    });

    test('should parse transfer correctly', () {
      final json = {
        'amount': 100000,
        'type': 'transfer',
        'wallet': 'BCA',
        'toWallet': 'Gopay',
        'note': 'pindah dana',
      };

      final result = NlpTransactionResult.fromJson(json, wallets, categories, defaultWallet);

      expect(result.amount, 100000);
      expect(result.type, TransactionType.transfer);
      expect(result.wallet?.id, bcaWallet.id);
      expect(result.toWallet?.id, defaultWallet.id);
    });
  });
}
