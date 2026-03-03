import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/category_repository_impl.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/data/tables/wallets_table.dart';

void main() {
  late AppDatabase db;
  late CategoryRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = CategoryRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryRepositoryImpl', () {
    test('creates and fetches categories', () async {
      final id = await repo.createCategory(
        CategoriesCompanion.insert(
          name: 'Games',
          iconCode: '🎮',
          type: TransactionType.expense,
        ),
      );

      expect(id, isPositive);

      final categories = await repo.watchAllCategories().first;
      final inserted = categories.firstWhere((c) => c.id == id);
      expect(inserted.name, 'Games');
      expect(inserted.iconCode, '🎮');
    });

    test('updates a category', () async {
      final id = await repo.createCategory(
        CategoriesCompanion.insert(
          name: 'Food',
          iconCode: '🍔',
          type: TransactionType.expense,
        ),
      );

      final categories = await repo.watchAllCategories().first;
      final category = categories.firstWhere((c) => c.id == id);
      final updatedCategory = category.copyWith(name: 'Groceries');

      final success = await repo.updateCategory(updatedCategory);
      expect(success, isTrue);

      final updatedCategories = await repo.watchAllCategories().first;
      final updated = updatedCategories.firstWhere((c) => c.id == id);
      expect(updated.name, 'Groceries');
    });

    test('deletes a category if not used', () async {
      final id = await repo.createCategory(
        CategoriesCompanion.insert(
          name: 'Travel',
          iconCode: '✈️',
          type: TransactionType.expense,
        ),
      );

      await repo.deleteCategory(id);

      final categories = await repo.watchAllCategories().first;
      expect(categories.any((c) => c.id == id), isFalse);
    });

    test('prevents deletion if used in transaction', () async {
      final catId = await repo.createCategory(
        CategoriesCompanion.insert(
          name: 'Food',
          iconCode: '🍔',
          type: TransactionType.expense,
        ),
      );

      // Insert a wallet first to satisfy the foreign key constraint
      await db
          .into(db.wallets)
          .insert(
            WalletsCompanion.insert(
              name: 'Cash',
              balance: const Value(100.0),
              type: WalletType.cash,
            ),
          );

      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              walletId: 1,
              amount: 50.0,
              type: TransactionType.expense,
              categoryId: catId,
              date: DateTime.now(),
            ),
          );

      expect(
        () async => await repo.deleteCategory(catId),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Category is currently in use'),
          ),
        ),
      );
    });

    test('fetches categories by type', () async {
      await repo.createCategory(
        CategoriesCompanion.insert(
          name: 'Food_Test',
          iconCode: '🍔',
          type: TransactionType.expense,
        ),
      );
      await repo.createCategory(
        CategoriesCompanion.insert(
          name: 'Salary_Test',
          iconCode: '💰',
          type: TransactionType.income,
        ),
      );

      final expenseCats = await repo
          .watchCategoriesByType(TransactionType.expense)
          .first;
      expect(expenseCats.any((c) => c.name == 'Food_Test'), isTrue);

      final incomeCats = await repo
          .watchCategoriesByType(TransactionType.income)
          .first;
      expect(incomeCats.any((c) => c.name == 'Salary_Test'), isTrue);
    });
  });
}
