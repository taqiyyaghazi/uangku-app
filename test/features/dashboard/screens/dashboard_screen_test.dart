import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/auth/state/auth_provider.dart';
import 'package:uangku/features/auth/models/user_profile.dart';
import 'package:uangku/features/dashboard/screens/dashboard_screen.dart';
import 'package:uangku/features/dashboard/widgets/wallet_carousel.dart';
import 'package:uangku/features/dashboard/widgets/wallet_grid.dart';
import 'package:uangku/features/dashboard/widgets/wallet_card.dart';
import 'package:uangku/features/dashboard/widgets/add_wallet_card.dart';
import 'package:uangku/features/sync/state/sync_status_provider.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';

class MockSyncStatusNotifier extends SyncStatusNotifier {
  @override
  SyncStatusState build() => SyncStatusState.idle();
}

class MockWalletRepository extends Mock implements WalletRepository {}

class FakeMonitoringService extends Mock implements MonitoringService {
  @override
  void logInfo(String message, [Map<String, Object>? context]) {}
  @override
  void logError(String message, dynamic exception, StackTrace stack, [Map<String, Object>? context]) {}
}

void main() {
  late SharedPreferences prefs;

  setUpAll(() {
    SharedPreferences.setMockInitialValues({'is_hidden': false});
  });

  setUp(() async {
    prefs = await SharedPreferences.getInstance();
  });

  Wallet makeWallet(int id) {
    final now = DateTime(2026, 3, 3);
    return Wallet(
      id: id,
      name: 'W$id',
      balance: 1000,
      type: WalletType.cash,
      colorHex: '#008080',
      icon: 'cash',
      createdAt: now,
      updatedAt: now,
    );
  }

  Widget buildTestWidget({
    required List<Wallet> wallets,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        walletsProvider.overrideWith((ref) => Stream.value(wallets)),
        dailyBreathProvider.overrideWith((ref) => const Stream.empty()),
        syncStatusProvider.overrideWith(() => MockSyncStatusNotifier()),
        authStateProvider.overrideWith((ref) => Stream.value(const UserProfile(id: '1'))),
        walletRepositoryProvider.overrideWithValue(MockWalletRepository()),
        recentTransactionsProvider.overrideWith((ref) => const Stream.empty()),
        monitoringServiceProvider.overrideWithValue(FakeMonitoringService()),
      ],
      child: const MaterialApp(
        home: DashboardScreen(),
      ),
    );
  }

  group('DashboardScreen Layout Logic', () {
    testWidgets('shows WalletCarousel when wallets > 2', (tester) async {
      final wallets = [makeWallet(1), makeWallet(2), makeWallet(3)];
      
      await tester.pumpWidget(buildTestWidget(wallets: wallets));
      await tester.pump(); 
      
      expect(find.byType(WalletCarousel), findsOneWidget);
    });

    testWidgets('shows WalletGrid when wallets == 2', (tester) async {
      final wallets = [makeWallet(1), makeWallet(2)];
      
      await tester.pumpWidget(buildTestWidget(wallets: wallets));
      await tester.pump();
      
      expect(find.byType(WalletGrid), findsOneWidget);
    });

    testWidgets('shows Single Big WalletCard and AddWalletCard when wallets == 1', (tester) async {
      final wallets = [makeWallet(1)];
      
      await tester.pumpWidget(buildTestWidget(wallets: wallets));
      await tester.pump();
      
      expect(find.byType(WalletCard), findsOneWidget);
      expect(find.byType(AddWalletCard), findsOneWidget);
    });

    testWidgets('shows WalletGrid (with only Add card) when wallets == 0', (tester) async {
      await tester.pumpWidget(buildTestWidget(wallets: []));
      await tester.pump();
      
      expect(find.byType(WalletGrid), findsOneWidget);
    });

    testWidgets('shows "See All" button next to "My Wallets" title', (tester) async {
      final wallets = [makeWallet(1)];

      await tester.pumpWidget(buildTestWidget(wallets: wallets));
      await tester.pump();

      expect(find.text('See All'), findsOneWidget);
      expect(find.byKey(const Key('see_all_wallets_button')), findsOneWidget);
    });
  });
}
