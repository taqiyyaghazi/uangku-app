import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/transaction/logic/transaction_balance_logic.dart';

void main() {
  final now = DateTime(2026, 3, 3);

  Transaction makeTx({
    double amount = 50000,
    TransactionType type = TransactionType.expense,
  }) {
    return Transaction(
      id: 1,
      walletId: 1,
      amount: amount,
      type: type,
      categoryId: 1,
      note: '',
      date: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('TransactionBalanceLogic.reversalDelta', () {
    test('deleting expense returns positive delta (add back)', () {
      final tx = makeTx(amount: 50000, type: TransactionType.expense);
      expect(TransactionBalanceLogic.reversalDelta(tx), 50000);
    });

    test('deleting income returns negative delta (subtract)', () {
      final tx = makeTx(amount: 100000, type: TransactionType.income);
      expect(TransactionBalanceLogic.reversalDelta(tx), -100000);
    });

    test('deleting transfer returns positive delta (add back to source)', () {
      final tx = makeTx(amount: 25000, type: TransactionType.transfer);
      expect(TransactionBalanceLogic.reversalDelta(tx), 25000);
    });
  });

  group('TransactionBalanceLogic.updateDelta', () {
    test('expense 50k → expense 70k: delta is -20k', () {
      final old = makeTx(amount: 50000, type: TransactionType.expense);
      final delta = TransactionBalanceLogic.updateDelta(
        old: old,
        newAmount: 70000,
        newType: TransactionType.expense,
      );
      // Reverse old: +50k, apply new: -70k → -20k
      expect(delta, -20000);
    });

    test('expense 50k → expense 30k: delta is +20k', () {
      final old = makeTx(amount: 50000, type: TransactionType.expense);
      final delta = TransactionBalanceLogic.updateDelta(
        old: old,
        newAmount: 30000,
        newType: TransactionType.expense,
      );
      // Reverse old: +50k, apply new: -30k → +20k
      expect(delta, 20000);
    });

    test('expense 50k → income 50k: delta is +100k', () {
      final old = makeTx(amount: 50000, type: TransactionType.expense);
      final delta = TransactionBalanceLogic.updateDelta(
        old: old,
        newAmount: 50000,
        newType: TransactionType.income,
      );
      // Reverse old: +50k, apply new: +50k → +100k
      expect(delta, 100000);
    });

    test('income 100k → expense 100k: delta is -200k', () {
      final old = makeTx(amount: 100000, type: TransactionType.income);
      final delta = TransactionBalanceLogic.updateDelta(
        old: old,
        newAmount: 100000,
        newType: TransactionType.expense,
      );
      // Reverse old: -100k, apply new: -100k → -200k
      expect(delta, -200000);
    });

    test('same amount and type gives zero delta', () {
      final old = makeTx(amount: 50000, type: TransactionType.expense);
      final delta = TransactionBalanceLogic.updateDelta(
        old: old,
        newAmount: 50000,
        newType: TransactionType.expense,
      );
      expect(delta, 0);
    });
  });
}
