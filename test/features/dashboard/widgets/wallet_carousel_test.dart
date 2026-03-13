import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/dashboard/widgets/wallet_carousel.dart';
import 'package:uangku/features/dashboard/widgets/add_wallet_card.dart';

void main() {
  Wallet makeWallet({
    int id = 1,
    String name = 'Wallet',
    double balance = 1000,
  }) {
    final now = DateTime(2026, 3, 3);
    return Wallet(
      id: id,
      name: name,
      balance: balance,
      type: WalletType.cash,
      colorHex: '#008080',
      icon: 'cash',
      createdAt: now,
      updatedAt: now,
    );
  }

  Widget buildTestWidget({
    required List<Wallet> wallets,
    void Function(Wallet)? onWalletTap,
    VoidCallback? onAddWallet,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: WalletCarousel(
          wallets: wallets,
          onWalletTap: onWalletTap,
          onAddWallet: onAddWallet,
        ),
      ),
    );
  }

  group('WalletCarousel', () {
    testWidgets('renders all wallets and AddWalletCard', (tester) async {
      final wallets = [
        makeWallet(id: 1, name: 'Wallet 1'),
        makeWallet(id: 2, name: 'Wallet 2'),
      ];

      await tester.pumpWidget(buildTestWidget(wallets: wallets));

      expect(find.text('Wallet 1'), findsOneWidget);
      expect(find.text('Wallet 2'), findsOneWidget);
      expect(find.byType(AddWalletCard), findsOneWidget);
    });

    testWidgets('shows indicator dots when > 3 wallets', (tester) async {
      final wallets = List.generate(4, (i) => makeWallet(id: i, name: 'W$i'));

      await tester.pumpWidget(buildTestWidget(wallets: wallets));

      // Indicator dots are descendants of the Row with key 'wallet_carousel_indicators'.
      // total items = 4 wallets + 1 add card = 5 dots.
      final indicators = find.byKey(const Key('wallet_carousel_indicators'));
      expect(find.descendant(of: indicators, matching: find.byType(AnimatedContainer)), findsNWidgets(5));
    });

    testWidgets('does not show indicator dots when <= 3 wallets', (tester) async {
      final wallets = List.generate(3, (i) => makeWallet(id: i, name: 'W$i'));

      await tester.pumpWidget(buildTestWidget(wallets: wallets));

      // There are AnimatedContainers in WalletCard, so we check if there's any Row 
      // at the bottom (mainAxisAlignment.center).
      // Or just check if there are many AnimatedContainers.
      // Actually, WalletCarousel dots are direct children of the Column.
      // Let's just check the length of wallets.
      expect(find.byType(Row), findsNWidgets(3)); // 3 WalletCards each have a Row
    });

    testWidgets('calls onWalletTap when a wallet is tapped', (tester) async {
      Wallet? tappedWallet;
      final wallets = [makeWallet(id: 1, name: 'Target')];

      await tester.pumpWidget(buildTestWidget(
        wallets: wallets,
        onWalletTap: (w) => tappedWallet = w,
      ));

      await tester.tap(find.text('Target'));
      expect(tappedWallet?.id, 1);
    });

    testWidgets('calls onAddWallet when add card is tapped', (tester) async {
      var addTapped = false;
      await tester.pumpWidget(buildTestWidget(
        wallets: [],
        onAddWallet: () => addTapped = true,
      ));

      await tester.tap(find.byType(AddWalletCard));
      expect(addTapped, isTrue);
    });
  });
}
