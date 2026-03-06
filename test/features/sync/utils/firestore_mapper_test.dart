import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/sync/utils/firestore_mapper.dart';

void main() {
  group('FirestoreMapper', () {
    final now = DateTime.now();

    test('walletToFirestore maps correctly', () {
      final wallet = Wallet(
        id: 1,
        name: 'Main Wallet',
        balance: 1000.0,
        type: WalletType.cash,
        colorHex: '#FFFFFF',
        icon: 'wallet',
        createdAt: now,
        updatedAt: now,
      );

      final map = FirestoreMapper.walletToFirestore(wallet);

      expect(map['id'], 1);
      expect(map['name'], 'Main Wallet');
      expect(map['balance'], 1000.0);
      expect(map['type'], 'cash');
      expect(map['createdAt'], isA<firestore.Timestamp>());
      expect((map['createdAt'] as firestore.Timestamp).toDate(), now);
    });

    test('walletFromFirestore maps correctly', () {
      final data = {
        'id': 1,
        'name': 'Main Wallet',
        'balance': 1000.0,
        'type': 'cash',
        'colorHex': '#FFFFFF',
        'icon': 'wallet',
        'createdAt': firestore.Timestamp.fromDate(now),
        'updatedAt': firestore.Timestamp.fromDate(now),
      };

      final wallet = FirestoreMapper.walletFromFirestore(data);

      expect(wallet.id, 1);
      expect(wallet.name, 'Main Wallet');
      expect(wallet.balance, 1000.0);
      expect(wallet.type, WalletType.cash);
      expect(wallet.createdAt, now);
    });

    test('transactionToFirestore maps correctly', () {
      final transaction = Transaction(
        id: 10,
        walletId: 1,
        amount: 50.0,
        type: TransactionType.expense,
        categoryId: 5,
        note: 'Coffee',
        date: now,
        createdAt: now,
        updatedAt: now,
      );

      final map = FirestoreMapper.transactionToFirestore(transaction);

      expect(map['id'], 10);
      expect(map['amount'], 50.0);
      expect(map['type'], 'expense');
      expect(map['note'], 'Coffee');
      expect(map['date'], isA<firestore.Timestamp>());
    });

    test('transactionFromFirestore maps correctly', () {
      final data = {
        'id': 10,
        'walletId': 1,
        'amount': 50.0,
        'type': 'expense',
        'categoryId': 5,
        'note': 'Coffee',
        'date': firestore.Timestamp.fromDate(now),
        'createdAt': firestore.Timestamp.fromDate(now),
        'updatedAt': firestore.Timestamp.fromDate(now),
      };

      final tx = FirestoreMapper.transactionFromFirestore(data);

      expect(tx.id, 10);
      expect(tx.amount, 50.0);
      expect(tx.note, 'Coffee');
      expect(tx.date, now);
    });

    test('categoryToFirestore maps correctly', () {
      final category = Category(
        id: 5,
        name: 'Food',
        iconCode: 'food',
        type: TransactionType.expense,
        createdAt: now,
        updatedAt: now,
      );

      final map = FirestoreMapper.categoryToFirestore(category);

      expect(map['id'], 5);
      expect(map['name'], 'Food');
      expect(map['type'], 'expense');
    });
  });
}
