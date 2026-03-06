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

    test('budgetToFirestore maps correctly', () {
      final budget = Budget(
        categoryId: 5,
        limitAmount: 1000.0,
        periodMonth: '2026-03',
        updatedAt: now,
      );

      final map = FirestoreMapper.budgetToFirestore(budget);

      expect(map['categoryId'], 5);
      expect(map['limitAmount'], 1000.0);
      expect(map['periodMonth'], '2026-03');
      expect(map['updatedAt'], isA<firestore.Timestamp>());
    });

    test('budgetFromFirestore maps correctly', () {
      final firestoreData = {
        'categoryId': 5,
        'limitAmount': 1000.0,
        'periodMonth': '2026-03',
        'updatedAt': firestore.Timestamp.fromDate(now),
      };

      final budget = FirestoreMapper.budgetFromFirestore(firestoreData);

      expect(budget.categoryId, 5);
      expect(budget.limitAmount, 1000.0);
      expect(budget.periodMonth, '2026-03');
      expect(budget.updatedAt, now);
    });

    test('investmentToFirestore maps correctly', () {
      final snapshot = InvestmentSnapshot(
        id: 1,
        walletId: 2,
        totalValue: 5000.0,
        snapshotDate: now,
      );

      final map = FirestoreMapper.investmentToFirestore(snapshot);

      expect(map['id'], 1);
      expect(map['walletId'], 2);
      expect(map['totalValue'], 5000.0);
      expect(map['snapshotDate'], isA<firestore.Timestamp>());
    });

    test('investmentFromFirestore maps correctly', () {
      final data = {
        'id': 1,
        'walletId': 2,
        'totalValue': 5000.0,
        'snapshotDate': firestore.Timestamp.fromDate(now),
      };

      final snapshot = FirestoreMapper.investmentFromFirestore(data);

      expect(snapshot.id, 1);
      expect(snapshot.walletId, 2);
      expect(snapshot.totalValue, 5000.0);
      expect(snapshot.snapshotDate, now);
    });
  });
}
