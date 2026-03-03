import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/dashboard/widgets/wallet_card.dart';

void main() {
  // Helper to create a test Wallet instance.
  Wallet makeWallet({
    int id = 1,
    String name = 'Bank BCA',
    double balance = 1250000,
    WalletType type = WalletType.bank,
    String colorHex = '#008080',
    String icon = 'bank',
  }) {
    final now = DateTime(2026, 3, 3);
    return Wallet(
      id: id,
      name: name,
      balance: balance,
      type: type,
      colorHex: colorHex,
      icon: icon,
      createdAt: now,
      updatedAt: now,
    );
  }

  Widget buildTestWidget(Wallet wallet, {VoidCallback? onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 200,
          height: 160,
          child: WalletCard(wallet: wallet, onTap: onTap),
        ),
      ),
    );
  }

  group('WalletCard', () {
    testWidgets('displays wallet name', (tester) async {
      await tester.pumpWidget(buildTestWidget(makeWallet()));
      expect(find.text('Bank BCA'), findsOneWidget);
    });

    testWidgets('displays formatted balance', (tester) async {
      await tester.pumpWidget(buildTestWidget(makeWallet()));
      expect(find.text('Rp 1.250.000'), findsOneWidget);
    });

    testWidgets('displays type label', (tester) async {
      await tester.pumpWidget(buildTestWidget(makeWallet()));
      expect(find.text('Bank'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestWidget(makeWallet(), onTap: () => tapped = true),
      );

      await tester.tap(find.byType(WalletCard));
      expect(tapped, isTrue);
    });

    testWidgets('handles zero balance', (tester) async {
      await tester.pumpWidget(buildTestWidget(makeWallet(balance: 0)));
      expect(find.text('Rp 0'), findsOneWidget);
    });

    testWidgets('handles invalid color hex gracefully', (tester) async {
      // Should not throw — falls back to teal.
      await tester.pumpWidget(
        buildTestWidget(makeWallet(colorHex: 'not-a-color')),
      );
      expect(find.text('Bank BCA'), findsOneWidget);
    });

    testWidgets('renders cash wallet type', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          makeWallet(name: 'My Cash', type: WalletType.cash, icon: 'cash'),
        ),
      );
      expect(find.text('My Cash'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
    });

    testWidgets('renders investment wallet type', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          makeWallet(
            name: 'Stocks',
            type: WalletType.investment,
            icon: 'stock',
          ),
        ),
      );
      expect(find.text('Stocks'), findsOneWidget);
      expect(find.text('Investment'), findsOneWidget);
    });
  });
}
