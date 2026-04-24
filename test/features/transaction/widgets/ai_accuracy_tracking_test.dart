import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:uangku/core/constants/app_constants.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/category_repository.dart';
import 'package:uangku/data/repositories/transaction_repository.dart';
import 'package:uangku/data/repositories/wallet_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/features/transaction/models/nlp_transaction_result.dart';
import 'package:uangku/features/transaction/widgets/quick_entry_sheet.dart';

import 'ai_accuracy_tracking_test.mocks.dart';

@GenerateMocks([
  MonitoringService,
  TransactionRepository,
  WalletRepository,
  CategoryRepository,
])
void main() {
  late MockMonitoringService mockMonitoring;
  late MockTransactionRepository mockTransactionRepo;
  late MockWalletRepository mockWalletRepo;
  late MockCategoryRepository mockCategoryRepo;

  final now = DateTime(2026, 4, 24);
  final fakeWallet = Wallet(
    id: 1,
    name: 'Cash',
    balance: 100000,
    type: WalletType.cash,
    colorHex: '#008080',
    icon: 'cash',
    createdAt: now,
    updatedAt: now,
  );
  final fakeCategory = Category(
    id: 1,
    name: 'Food',
    iconCode: 'fastfood',
    type: TransactionType.expense,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockMonitoring = MockMonitoringService();
    mockTransactionRepo = MockTransactionRepository();
    mockWalletRepo = MockWalletRepository();
    mockCategoryRepo = MockCategoryRepository();

    when(mockWalletRepo.watchAllWallets()).thenAnswer((_) => Stream.value([fakeWallet]));
    when(mockCategoryRepo.watchCategoriesByType(any)).thenAnswer((_) => Stream.value([fakeCategory]));
    when(mockTransactionRepo.watchRecentTransactions(any)).thenAnswer((_) => Stream.value([]));
    when(mockTransactionRepo.insertTransactionAndUpdateBalance(
      transaction: anyNamed('transaction'),
      walletId: anyNamed('walletId'),
      balanceDelta: anyNamed('balanceDelta'),
    )).thenAnswer((_) => Future.value(1));
  });

  Widget buildTestWidget({NlpTransactionResult? initialNlpResult}) {
    return ProviderScope(
      overrides: [
        monitoringServiceProvider.overrideWithValue(mockMonitoring),
        transactionRepositoryProvider.overrideWithValue(mockTransactionRepo),
        walletRepositoryProvider.overrideWithValue(mockWalletRepo),
        categoryRepositoryProvider.overrideWithValue(mockCategoryRepo),
        walletsProvider.overrideWith((ref) => Stream.value([fakeWallet])),
        categoriesByTypeProvider(TransactionType.expense).overrideWith((ref) => Stream.value([fakeCategory])),
        categoriesByTypeProvider(TransactionType.income).overrideWith((ref) => Stream.value([fakeCategory])),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 1200,
            child: QuickEntrySheet(initialNlpResult: initialNlpResult),
          ),
        ),
      ),
    );
  }

  group('QuickEntrySheet AI Accuracy Tracking', () {
    testWidgets('logs accuracy=1 when saving unchanged NLP result', (tester) async {
      final nlpResult = NlpTransactionResult(
        amount: 50000,
        type: TransactionType.expense,
        wallet: fakeWallet,
        category: fakeCategory,
        note: 'lunch',
        date: now,
      );

      await tester.pumpWidget(buildTestWidget(initialNlpResult: nlpResult));
      await tester.pumpAndSettle();

      final saveButton = find.text('Save');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      verify(mockMonitoring.logAiAccuracy(
        method: AppConstants.methodNlpChat,
        aiCategory: 'Food',
        finalCategory: 'Food',
      )).called(1);
    });

    testWidgets('logs accuracy=0 when category is changed after NLP result', (tester) async {
      final otherCategory = Category(
        id: 2,
        name: 'Shopping',
        iconCode: 'shopping_bag',
        type: TransactionType.expense,
        createdAt: now,
        updatedAt: now,
      );
      
      when(mockCategoryRepo.watchCategoriesByType(TransactionType.expense))
          .thenAnswer((_) => Stream.value([fakeCategory, otherCategory]));

      final nlpResult = NlpTransactionResult(
        amount: 50000,
        type: TransactionType.expense,
        wallet: fakeWallet,
        category: fakeCategory,
        note: 'lunch',
        date: now,
      );

      await tester.pumpWidget(ProviderScope(
        overrides: [
          monitoringServiceProvider.overrideWithValue(mockMonitoring),
          transactionRepositoryProvider.overrideWithValue(mockTransactionRepo),
          walletRepositoryProvider.overrideWithValue(mockWalletRepo),
          categoryRepositoryProvider.overrideWithValue(mockCategoryRepo),
          walletsProvider.overrideWith((ref) => Stream.value([fakeWallet])),
          categoriesByTypeProvider(TransactionType.expense).overrideWith((ref) => Stream.value([fakeCategory, otherCategory])),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 1200,
              child: QuickEntrySheet(initialNlpResult: nlpResult),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Change category to Shopping
      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Shopping'));
      await tester.pumpAndSettle();

      final saveButton = find.text('Save');
      await tester.ensureVisible(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      verify(mockMonitoring.logAiAccuracy(
        method: AppConstants.methodNlpChat,
        aiCategory: 'Food',
        finalCategory: 'Shopping',
      )).called(1);
    });
  });
}
