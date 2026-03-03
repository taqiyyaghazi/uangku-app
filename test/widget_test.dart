import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/features/dashboard/screens/dashboard_screen.dart';

/// A fake WalletRepository that returns an empty stream for testing.
class FakeWalletRepository implements WalletRepository {
  @override
  Stream<List<Wallet>> watchAllWallets() => Stream.value([]);

  @override
  Future<int> createWallet(WalletsCompanion wallet) async => 1;

  @override
  Future<bool> updateWallet(WalletsCompanion wallet) async => true;

  @override
  Future<bool> deleteWallet(int id) async => true;

  @override
  Future<Wallet?> getWalletById(int id) async => null;
}

void main() {
  testWidgets('Dashboard renders with empty wallet state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletsProvider.overrideWith((_) => Stream.value(<Wallet>[])),
          walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Should show "My Wallets" section title and "Add Wallet" card.
    expect(find.text('My Wallets'), findsOneWidget);
    expect(find.text('Add Wallet'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('Rp 0'), findsOneWidget);
  });
}
