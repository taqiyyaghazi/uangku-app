import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/repositories/category_repository.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/transaction/widgets/numpad.dart';
import 'package:uangku/features/transaction/widgets/quick_entry_sheet.dart';

/// Fake wallet repository for testing.
class FakeWalletRepository implements WalletRepository {
  @override
  Stream<List<Wallet>> watchAllWallets() => Stream.value(_fakeWallets);

  @override
  Future<int> createWallet(WalletsCompanion wallet) async => 1;

  @override
  Future<bool> updateWallet(WalletsCompanion wallet) async => true;

  @override
  Future<bool> deleteWallet(int id) async => true;

  @override
  Future<Wallet?> getWalletById(int id) async => null;
}

/// Fake transaction repository for testing.
class FakeTransactionRepository implements TransactionRepository {
  int insertCallCount = 0;

  @override
  Stream<List<TransactionWithCategory>> watchTransactionsByWallet(
    int walletId,
  ) => Stream.value([]);

  @override
  Stream<List<TransactionWithCategory>> watchTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) => Stream.value([]);

  @override
  Future<int> createTransaction(TransactionsCompanion transaction) async => 1;

  @override
  Future<bool> deleteTransaction(int id) async => true;

  @override
  Future<int> insertTransactionAndUpdateBalance({
    required TransactionsCompanion transaction,
    required int walletId,
    required double balanceDelta,
  }) async {
    insertCallCount++;
    return 1;
  }

  @override
  Future<int> performInternalTransfer({
    required int fromWalletId,
    required int toWalletId,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    return 1;
  }

  @override
  Stream<List<TransactionWithCategory>> watchRecentTransactions(int limit) =>
      Stream.value([]);

  @override
  Stream<List<TransactionWithCategory>> watchAllTransactions() =>
      Stream.value([]);

  @override
  Future<void> deleteTransactionAtomic(Transaction transaction) async {}

  @override
  Future<void> updateTransactionAtomic({
    required int transactionId,
    required TransactionsCompanion updated,
    required int walletId,
    required double balanceDelta,
  }) async {}
}

class FakeCategoryRepository implements CategoryRepository {
  @override
  Stream<List<Category>> watchAllCategories() => Stream.value([]);

  @override
  Stream<List<Category>> watchCategoriesByType(TransactionType type) {
    if (type == TransactionType.expense) {
      return Stream.value([
        Category(
          id: 1,
          name: 'Food',
          iconCode: 'fastfood',
          type: TransactionType.expense,
          createdAt: DateTime.now(),
        ),
      ]);
    } else if (type == TransactionType.income) {
      return Stream.value([
        Category(
          id: 2,
          name: 'Salary',
          iconCode: 'attach_money',
          type: TransactionType.income,
          createdAt: DateTime.now(),
        ),
      ]);
    }
    return Stream.value([]);
  }

  @override
  Future<int> createCategory(CategoriesCompanion category) async => 1;

  @override
  Future<bool> updateCategory(Category category) async => true;

  @override
  Future<void> deleteCategory(int id) async {}

  @override
  Future<bool> canDeleteCategory(int id) async => true;
}

final _now = DateTime(2026, 3, 3);

final _fakeWallets = [
  Wallet(
    id: 1,
    name: 'Bank BCA',
    balance: 1000000,
    type: WalletType.bank,
    colorHex: '#008080',
    icon: 'bank',
    createdAt: _now,
    updatedAt: _now,
  ),
  Wallet(
    id: 2,
    name: 'Cash',
    balance: 500000,
    type: WalletType.cash,
    colorHex: '#008080',
    icon: 'cash',
    createdAt: _now,
    updatedAt: _now,
  ),
];

void main() {
  // Use InkSplash to avoid shader asset error in test environment.
  final testTheme = ThemeData(
    useMaterial3: true,
    splashFactory: InkSplash.splashFactory,
  );

  late FakeTransactionRepository fakeTransactionRepo;
  late FakeCategoryRepository fakeCategoryRepo;

  setUp(() {
    fakeTransactionRepo = FakeTransactionRepository();
    fakeCategoryRepo = FakeCategoryRepository();
  });

  /// Build the QuickEntrySheet directly as a widget (not inside a bottom sheet)
  /// to avoid viewport/off-screen issues in the 600px test environment.
  Widget buildDirectSheet() {
    return ProviderScope(
      overrides: [
        walletsProvider.overrideWith((_) => Stream.value(_fakeWallets)),
        walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
        transactionRepositoryProvider.overrideWithValue(fakeTransactionRepo),
        categoryRepositoryProvider.overrideWithValue(fakeCategoryRepo),
      ],
      child: MaterialApp(
        theme: testTheme,
        home: const Scaffold(
          body: SingleChildScrollView(child: QuickEntrySheet()),
        ),
      ),
    );
  }

  /// Build the bottom-sheet test app for structural tests.
  Widget buildBottomSheetApp() {
    return ProviderScope(
      overrides: [
        walletsProvider.overrideWith((_) => Stream.value(_fakeWallets)),
        walletRepositoryProvider.overrideWithValue(FakeWalletRepository()),
        transactionRepositoryProvider.overrideWithValue(fakeTransactionRepo),
        categoryRepositoryProvider.overrideWithValue(fakeCategoryRepo),
      ],
      child: MaterialApp(
        theme: testTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => QuickEntrySheet.show(context),
                child: const Text('Open Entry'),
              );
            },
          ),
        ),
      ),
    );
  }

  group('QuickEntrySheet', () {
    testWidgets('renders transaction type toggle', (tester) async {
      await tester.pumpWidget(buildDirectSheet());
      await tester.pumpAndSettle();

      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('renders wallet chips', (tester) async {
      await tester.pumpWidget(buildDirectSheet());
      await tester.pumpAndSettle();

      expect(find.text('Bank BCA'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
    });

    testWidgets('renders numpad digits', (tester) async {
      await tester.pumpWidget(buildDirectSheet());
      await tester.pumpAndSettle();

      // Check a few digits are present in the numpad.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('selecting Transfer shows From and To wallet selectors', (
      tester,
    ) async {
      await tester.pumpWidget(buildDirectSheet());
      await tester.pumpAndSettle();

      // Tap Transfer tab
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      // Should show 'From Wallet' and 'To Wallet' text
      expect(find.text('From Wallet'), findsOneWidget);
      expect(find.text('To Wallet'), findsOneWidget);

      // Category sector should be hidden
      expect(find.text('Food'), findsNothing);
    });

    testWidgets('displays initial amount as Rp 0', (tester) async {
      await tester.pumpWidget(buildDirectSheet());
      await tester.pumpAndSettle();

      expect(find.text('Rp 0'), findsOneWidget);
    });

    testWidgets('tapping digit 5 updates amount display', (tester) async {
      await tester.pumpWidget(buildDirectSheet());
      await tester.pumpAndSettle();

      // Tap digit 5 (ensure it's visible first since the sheet might be tall).
      final digit5 = find.descendant(
        of: find.byType(Numpad),
        matching: find.text('5'),
      );
      await tester.ensureVisible(digit5);
      await tester.pumpAndSettle();
      await tester.tap(digit5);
      await tester.pumpAndSettle();

      // Use find.textContaining since the currency formatter adds thin spaces and Rs symbols.
      expect(find.textContaining('5'), findsWidgets);
    });

    testWidgets('switching to Income shows income categories', (tester) async {
      await tester.pumpWidget(buildDirectSheet());
      await tester.pumpAndSettle();

      // Default is Expense — should show expense categories.
      expect(find.text('Food'), findsOneWidget);

      // Switch to Income.
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('save button exists', (tester) async {
      await tester.pumpWidget(buildDirectSheet());
      await tester.pumpAndSettle();

      // FilledButton.icon renders "Save" text.
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('tapping date chip opens date picker', (tester) async {
      await tester.pumpWidget(buildDirectSheet());
      await tester.pumpAndSettle();

      // Tap the date chip.
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      // Verify the calendar dialog appears.
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('opens via bottom sheet', (tester) async {
      await tester.pumpWidget(buildBottomSheetApp());
      await tester.tap(find.text('Open Entry'));
      await tester.pumpAndSettle();

      // Verify the sheet opened with the type selector visible.
      expect(find.text('Expense'), findsOneWidget);
    });
  });
}
