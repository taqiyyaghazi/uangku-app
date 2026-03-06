import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/category_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/category/screens/category_list_screen.dart';

class FakeCategoryRepository implements CategoryRepository {
  @override
  Stream<List<Category>> watchAllCategories() => Stream.value([]);

  @override
  Stream<List<Category>> watchCategoriesByType(TransactionType type) =>
      Stream.value([
        Category(
          id: 1,
          name: 'Test Category',
          iconCode: '👍',
          type: type,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ]);

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
  testWidgets('CategoryListScreen renders tabs and lists', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(
            FakeCategoryRepository(),
          ),
        ],
        child: const MaterialApp(home: CategoryListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Manage Categories'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Test Category'), findsWidgets);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
