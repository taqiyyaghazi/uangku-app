import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/dashboard/screens/wallet_list_screen.dart';
import 'package:uangku/features/dashboard/widgets/wallet_list_item.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

class FakeMonitoringService extends Mock implements MonitoringService {
  @override
  void logInfo(String message, [Map<String, Object>? context]) {}
  @override
  void logError(String message, dynamic exception, StackTrace stack,
      [Map<String, Object>? context]) {}
}

void main() {
  late SharedPreferences prefs;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({'is_hidden': false});
  });

  setUp(() async {
    prefs = await SharedPreferences.getInstance();
  });

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

  Widget buildTestWidget({required List<Wallet> wallets}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        walletsProvider.overrideWith((ref) => Stream.value(wallets)),
        walletRepositoryProvider.overrideWithValue(MockWalletRepository()),
        monitoringServiceProvider.overrideWithValue(FakeMonitoringService()),
      ],
      child: const MaterialApp(
        home: WalletListScreen(),
      ),
    );
  }

  group('WalletListScreen', () {
    testWidgets('renders wallet list items for each wallet', (tester) async {
      final wallets = [
        makeWallet(id: 1, name: 'Bank BCA'),
        makeWallet(id: 2, name: 'Cash Wallet'),
        makeWallet(id: 3, name: 'Gopay'),
      ];

      await tester.pumpWidget(buildTestWidget(wallets: wallets));
      await tester.pump();

      expect(find.byType(WalletListItem), findsNWidgets(3));
      expect(find.text('Bank BCA'), findsOneWidget);
      expect(find.text('Cash Wallet'), findsOneWidget);
      expect(find.text('Gopay'), findsOneWidget);
    });

    testWidgets('search field filters list in real-time', (tester) async {
      final wallets = [
        makeWallet(id: 1, name: 'Bank BCA'),
        makeWallet(id: 2, name: 'Cash Wallet'),
        makeWallet(id: 3, name: 'Bank Mandiri'),
      ];

      await tester.pumpWidget(buildTestWidget(wallets: wallets));
      await tester.pump();

      // Type "bank" in the search field
      await tester.enterText(
        find.byKey(const Key('wallet_search_field')),
        'bank',
      );
      await tester.pump();

      expect(find.byType(WalletListItem), findsNWidgets(2));
      expect(find.text('Bank BCA'), findsOneWidget);
      expect(find.text('Bank Mandiri'), findsOneWidget);
      expect(find.text('Cash Wallet'), findsNothing);
    });

    testWidgets('shows empty search state when no results', (tester) async {
      final wallets = [
        makeWallet(id: 1, name: 'Bank BCA'),
      ];

      await tester.pumpWidget(buildTestWidget(wallets: wallets));
      await tester.pump();

      await tester.enterText(
        find.byKey(const Key('wallet_search_field')),
        'zzz',
      );
      await tester.pump();

      expect(find.byKey(const Key('wallet_search_empty_state')), findsOneWidget);
      expect(find.text('Dompetnya sembunyi di mana ya?'), findsOneWidget);
    });

    testWidgets('FAB is visible', (tester) async {
      await tester.pumpWidget(buildTestWidget(wallets: [makeWallet()]));
      await tester.pump();

      expect(find.byKey(const Key('wallet_list_fab')), findsOneWidget);
    });

    testWidgets('shows empty wallet state when no wallets exist',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(wallets: []));
      await tester.pump();

      expect(find.byKey(const Key('wallet_list_empty_state')), findsOneWidget);
      expect(find.text('No wallets yet'), findsOneWidget);
    });

    testWidgets('clear button resets search', (tester) async {
      final wallets = [
        makeWallet(id: 1, name: 'Bank BCA'),
        makeWallet(id: 2, name: 'Cash Wallet'),
      ];

      await tester.pumpWidget(buildTestWidget(wallets: wallets));
      await tester.pump();

      // Search for "bank"
      await tester.enterText(
        find.byKey(const Key('wallet_search_field')),
        'bank',
      );
      await tester.pump();
      expect(find.byType(WalletListItem), findsNWidgets(1));

      // Tap clear button
      await tester.tap(find.byKey(const Key('wallet_search_clear')));
      await tester.pump();

      // All wallets should be visible again
      expect(find.byType(WalletListItem), findsNWidgets(2));
    });

    testWidgets('first wallet marked as primary when not searching',
        (tester) async {
      final wallets = [
        makeWallet(id: 1, name: 'Primary Wallet'),
        makeWallet(id: 2, name: 'Secondary'),
      ];

      await tester.pumpWidget(buildTestWidget(wallets: wallets));
      await tester.pump();

      // The first item should have a "Primary" badge
      expect(find.text('Primary'), findsOneWidget);
    });

    testWidgets('displays app bar title', (tester) async {
      await tester.pumpWidget(buildTestWidget(wallets: [makeWallet()]));
      await tester.pump();

      expect(find.text('My Wallets'), findsOneWidget);
    });
  });
}
