import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/investment_repository.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/portfolio/widgets/asset_update_sheet.dart';

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

class FakeInvestmentRepository implements InvestmentRepository {
  int recordCallCount = 0;

  @override
  Stream<List<InvestmentSnapshot>> watchSnapshotsByWallet(int walletId) =>
      Stream.value([]);

  @override
  Future<int> recordSnapshotAndUpdateBalance({
    required int walletId,
    required double newValue,
  }) async {
    recordCallCount++;
    return 1;
  }
}

final _now = DateTime(2026, 3, 3);

final _testWallet = Wallet(
  id: 1,
  name: 'Stocks',
  balance: 5000000,
  type: WalletType.investment,
  colorHex: '#008080',
  icon: 'trending_up',
  createdAt: _now,
  updatedAt: _now,
);

void main() {
  final testTheme = ThemeData(
    useMaterial3: true,
    splashFactory: InkSplash.splashFactory,
  );

  late FakeInvestmentRepository fakeInvestmentRepo;

  setUp(() {
    fakeInvestmentRepo = FakeInvestmentRepository();
  });

  Widget buildTestApp() {
    return ProviderScope(
      overrides: [
        walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
        investmentRepositoryProvider.overrideWithValue(fakeInvestmentRepo),
      ],
      child: MaterialApp(
        theme: testTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () =>
                    AssetUpdateSheet.show(context, wallet: _testWallet),
                child: const Text('Open Sheet'),
              );
            },
          ),
        ),
      ),
    );
  }

  group('AssetUpdateSheet', () {
    testWidgets('shows wallet name in title', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Update Stocks'), findsOneWidget);
    });

    testWidgets('shows current value as reference', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Current value:'), findsOneWidget);
      expect(find.textContaining('Rp 5.000.000'), findsOneWidget);
    });

    testWidgets('pre-fills with current balance', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      final textField = find.widgetWithText(TextFormField, 'New Asset Value');
      expect(textField, findsOneWidget);
    });

    testWidgets('validates empty input', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Clear the field.
      final textField = find.widgetWithText(TextFormField, 'New Asset Value');
      await tester.enterText(textField, '');

      // Tap save.
      await tester.tap(find.text('Save Snapshot'));
      await tester.pumpAndSettle();

      expect(find.text('Value is required'), findsOneWidget);
    });

    testWidgets('saves snapshot with valid input', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Enter new value.
      final textField = find.widgetWithText(TextFormField, 'New Asset Value');
      await tester.enterText(textField, '6000000');

      // Tap save.
      await tester.tap(find.text('Save Snapshot'));
      await tester.pumpAndSettle();

      expect(fakeInvestmentRepo.recordCallCount, 1);
    });
  });
}
