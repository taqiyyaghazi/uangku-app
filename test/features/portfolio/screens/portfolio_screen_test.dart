import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/investment_repository.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/portfolio/logic/portfolio_providers.dart';
import 'package:uangku/features/portfolio/screens/portfolio_screen.dart';

class FakeWalletRepository implements WalletRepository {
  final List<Wallet> wallets;
  FakeWalletRepository(this.wallets);

  @override
  Stream<List<Wallet>> watchAllWallets() => Stream.value(wallets);
  @override
  Future<int> createWallet(WalletsCompanion wallet) async => 1;
  @override
  Future<bool> updateWallet(WalletsCompanion wallet) async => true;
  @override
  Future<bool> deleteWallet(int id) async => true;
  @override
  Future<Wallet?> getWalletById(int id) async => null;
}

class FakeInvestmentRepository implements InvestmentRepository {
  @override
  Stream<List<InvestmentSnapshot>> watchSnapshotsByWallet(int walletId) =>
      Stream.value([]);
  @override
  Future<int> recordSnapshotAndUpdateBalance({
    required int walletId,
    required double newValue,
  }) async => 1;
}

final _now = DateTime(2026, 3, 3);

void main() {
  final testTheme = ThemeData(
    useMaterial3: true,
    splashFactory: InkSplash.splashFactory,
  );

  group('PortfolioScreen', () {
    testWidgets('shows empty state when no investment wallets', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletsProvider.overrideWith((_) => Stream.value(<Wallet>[])),
            walletRepositoryProvider.overrideWithValue(
              FakeWalletRepository([]),
            ),
            investmentRepositoryProvider.overrideWithValue(
              FakeInvestmentRepository(),
            ),
            netWorthGrowthProvider.overrideWith((_) => Future.value([])),
            walletAllocationProvider.overrideWith((_) => []),
          ],
          child: MaterialApp(theme: testTheme, home: const PortfolioScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('No investment wallets yet'), findsOneWidget);
    });

    testWidgets('shows investment wallets with Update button', (tester) async {
      final wallets = [
        Wallet(
          id: 1,
          name: 'Stocks',
          balance: 5000000,
          type: WalletType.investment,
          colorHex: '#008080',
          icon: 'trending_up',
          createdAt: _now,
          updatedAt: _now,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletsProvider.overrideWith((_) => Stream.value(wallets)),
            walletRepositoryProvider.overrideWithValue(
              FakeWalletRepository(wallets),
            ),
            investmentRepositoryProvider.overrideWithValue(
              FakeInvestmentRepository(),
            ),
            netWorthGrowthProvider.overrideWith((_) => Future.value([])),
            walletAllocationProvider.overrideWith((_) => []),
          ],
          child: MaterialApp(theme: testTheme, home: const PortfolioScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Stocks'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });

    testWidgets('filters out non-investment wallets', (tester) async {
      final wallets = [
        Wallet(
          id: 1,
          name: 'Cash Wallet',
          balance: 100000,
          type: WalletType.cash,
          colorHex: '#008080',
          icon: 'cash',
          createdAt: _now,
          updatedAt: _now,
        ),
        Wallet(
          id: 2,
          name: 'Gold Fund',
          balance: 3000000,
          type: WalletType.investment,
          colorHex: '#008080',
          icon: 'trending_up',
          createdAt: _now,
          updatedAt: _now,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletsProvider.overrideWith((_) => Stream.value(wallets)),
            walletRepositoryProvider.overrideWithValue(
              FakeWalletRepository(wallets),
            ),
            investmentRepositoryProvider.overrideWithValue(
              FakeInvestmentRepository(),
            ),
            netWorthGrowthProvider.overrideWith((_) => Future.value([])),
            walletAllocationProvider.overrideWith((_) => []),
          ],
          child: MaterialApp(theme: testTheme, home: const PortfolioScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Gold Fund'), findsOneWidget);
      expect(find.text('Cash Wallet'), findsNothing);
    });

    testWidgets('shows Portfolio title in app bar', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            walletsProvider.overrideWith((_) => Stream.value(<Wallet>[])),
            walletRepositoryProvider.overrideWithValue(
              FakeWalletRepository([]),
            ),
            investmentRepositoryProvider.overrideWithValue(
              FakeInvestmentRepository(),
            ),
            netWorthGrowthProvider.overrideWith((_) => Future.value([])),
            walletAllocationProvider.overrideWith((_) => []),
          ],
          child: MaterialApp(theme: testTheme, home: const PortfolioScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Portfolio'), findsOneWidget);
    });
  });
}
