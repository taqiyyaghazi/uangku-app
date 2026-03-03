import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/features/dashboard/models/budget_state.dart';
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

/// A default [BudgetState] with zero values for tests.
const _emptyBudgetState = BudgetState(
  monthlyLimit: 0,
  totalSpentThisMonth: 0,
  spentToday: 0,
  dailyAllowance: 0,
  remainingDays: 1,
  remainingBudget: 0,
  progressRatio: 0,
  isOverspent: false,
);

void main() {
  testWidgets('Dashboard renders with empty wallet state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          walletsProvider.overrideWith((_) => Stream.value(<Wallet>[])),
          walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
          // Override to avoid real Drift streams, which schedule timers on
          // disposal and cause "A Timer is still pending" failures.
          dailyBreathProvider.overrideWith(
            (_) => Stream.value(_emptyBudgetState),
          ),
          recentTransactionsProvider.overrideWith(
            (_) => Stream.value(<Transaction>[]),
          ),
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
