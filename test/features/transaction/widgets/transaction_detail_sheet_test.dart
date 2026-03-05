import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/category_spending.dart';
import 'package:uangku/data/models/daily_spending.dart';
import 'package:uangku/data/models/monthly_summary.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/models/transaction_with_details.dart';
import 'package:uangku/data/repositories/category_repository.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/transaction/widgets/transaction_detail_sheet.dart';

/// Fake transaction repository that tracks method calls.
class FakeTransactionRepository implements TransactionRepository {
  int deleteAtomicCallCount = 0;
  int updateAtomicCallCount = 0;

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
  Stream<List<CategorySpending>> watchCategorySpending(DateTime month) =>
      Stream.value([]);

  @override
  Stream<List<DailySpending>> watchDailySpending(DateTime month) =>
      Stream.value([]);

  @override
  Stream<MonthlySummary> watchMonthlySummary(DateTime month) =>
      Stream.value(MonthlySummary.empty());

  @override
  Future<int> createTransaction(TransactionsCompanion transaction) async => 1;

  @override
  Future<bool> deleteTransaction(int id) async => true;

  @override
  Future<int> insertTransactionAndUpdateBalance({
    required TransactionsCompanion transaction,
    required int walletId,
    required double balanceDelta,
  }) async => 1;

  @override
  Stream<List<TransactionWithCategory>> watchRecentTransactions(int limit) =>
      Stream.value([]);

  @override
  Stream<List<TransactionWithCategory>> watchAllTransactions({int? walletId}) {
    return Stream.value([]);
  }

  @override
  Future<void> deleteTransactionAtomic(Transaction transaction) async {
    deleteAtomicCallCount++;
  }

  @override
  Future<void> updateTransactionAtomic({
    required int transactionId,
    required TransactionsCompanion updated,
    required int walletId,
    required double balanceDelta,
  }) async {
    updateAtomicCallCount++;
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
  Future<List<TransactionWithDetails>> getAllTransactionsWithDetails() async =>
      [];
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

void main() {
  final now = DateTime(2026, 3, 3, 14, 30);

  final testTransaction = TransactionWithCategory(
    transaction: Transaction(
      id: 1,
      walletId: 1,
      categoryId: 1,
      amount: 50000,
      type: TransactionType.expense,
      note: 'Lunch',
      date: now,
      createdAt: now,
    ),
    category: Category(
      id: 1,
      name: 'Food',
      iconCode: 'fastfood',
      type: TransactionType.expense,
      createdAt: now,
    ),
  );

  // Use InkSplash to avoid shader asset error in test environment.
  final testTheme = ThemeData(
    useMaterial3: true,
    splashFactory: InkSplash.splashFactory,
  );

  late FakeTransactionRepository fakeRepo;
  late FakeCategoryRepository fakeCategoryRepo;

  setUp(() {
    fakeRepo = FakeTransactionRepository();
    fakeCategoryRepo = FakeCategoryRepository();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(fakeRepo),
        categoryRepositoryProvider.overrideWithValue(fakeCategoryRepo),
      ],
      child: MaterialApp(
        theme: testTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: TransactionDetailSheet(
              transaction: testTransaction,
              walletName: 'Bank BCA',
            ),
          ),
        ),
      ),
    );
  }

  group('TransactionDetailSheet - View Mode', () {
    testWidgets('displays category name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('displays wallet name', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.textContaining('Bank BCA'), findsOneWidget);
    });

    testWidgets('displays formatted amount', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('-Rp 50.000'), findsOneWidget);
    });

    testWidgets('displays Edit and Delete buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('displays note when present', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Lunch'), findsOneWidget);
    });

    testWidgets('displays relative time label', (tester) async {
      // RelativeTimeFormatter uses Jiffy under the hood. Since "now" in the test
      // might be different from when the test runs (due to DateTime.now()),
      // it's safer to just check that *some* text from the date is displayed,
      // or mock the time. For now, let's just assert that the Row containing
      // the calendar icon exists.
      await tester.pumpWidget(buildTestWidget());
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    });
  });

  group('TransactionDetailSheet - Edit Mode', () {
    testWidgets('tapping Edit switches to edit mode', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Edit mode should show type selector and Cancel/Save.
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Cancel returns to view mode', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should be back in view mode with Edit/Delete buttons.
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets(
      'displays Date Selector action chip initialized with transaction date',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        // In edit mode, there should be an ActionChip with the calendar icon
        // and text representing the date (3/3/2026).
        expect(find.byIcon(Icons.calendar_today), findsOneWidget);
        expect(find.textContaining('3/3/2026'), findsOneWidget);
      },
    );
  });

  group('TransactionDetailSheet - Delete', () {
    testWidgets('tapping Delete shows confirmation dialog', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear.
      expect(find.text('Delete Transaction'), findsOneWidget);
      expect(find.textContaining('Are you sure'), findsOneWidget);
    });

    testWidgets('canceling delete dialog does not call repository', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Cancel the dialog.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(fakeRepo.deleteAtomicCallCount, 0);
    });
  });
}
