import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/dashboard/logic/wallet_search_logic.dart';

void main() {
  // Helper to create a test Wallet instance.
  Wallet makeWallet({
    int id = 1,
    String name = 'Bank BCA',
    double balance = 1250000,
    WalletType type = WalletType.bank,
  }) {
    final now = DateTime(2026, 3, 3);
    return Wallet(
      id: id,
      name: name,
      balance: balance,
      type: type,
      colorHex: '#008080',
      icon: 'bank',
      createdAt: now,
      updatedAt: now,
    );
  }

  group('filterWallets', () {
    final wallets = [
      makeWallet(id: 1, name: 'Bank BCA'),
      makeWallet(id: 2, name: 'Cash Wallet'),
      makeWallet(id: 3, name: 'Gopay Digital'),
      makeWallet(id: 4, name: 'Bank Mandiri'),
    ];

    test('returns all wallets when query is empty', () {
      final result = filterWallets(wallets, '');
      expect(result, equals(wallets));
    });

    test('returns all wallets when query is whitespace only', () {
      final result = filterWallets(wallets, '   ');
      expect(result, equals(wallets));
    });

    test('filters by name case-insensitively', () {
      final result = filterWallets(wallets, 'bank');
      expect(result.length, 2);
      expect(result[0].name, 'Bank BCA');
      expect(result[1].name, 'Bank Mandiri');
    });

    test('filters with uppercase query', () {
      final result = filterWallets(wallets, 'CASH');
      expect(result.length, 1);
      expect(result[0].name, 'Cash Wallet');
    });

    test('filters with partial match', () {
      final result = filterWallets(wallets, 'go');
      expect(result.length, 1);
      expect(result[0].name, 'Gopay Digital');
    });

    test('returns empty list when no match', () {
      final result = filterWallets(wallets, 'zzz');
      expect(result, isEmpty);
    });

    test('returns empty list when source list is empty', () {
      final result = filterWallets([], 'bank');
      expect(result, isEmpty);
    });

    test('handles special characters in query gracefully', () {
      final result = filterWallets(wallets, r'$pecial!@#');
      expect(result, isEmpty);
    });
  });
}
