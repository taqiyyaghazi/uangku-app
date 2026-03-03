import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/category_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/category/widgets/category_form_sheet.dart';

class FakeCategoryRepository implements CategoryRepository {
  @override
  Stream<List<Category>> watchAllCategories() => Stream.value([]);

  @override
  Stream<List<Category>> watchCategoriesByType(TransactionType type) =>
      Stream.value([]);

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
  testWidgets('CategoryFormSheet renders form fields', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(
            FakeCategoryRepository(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: CategoryFormSheet())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('New Category'), findsOneWidget);
    expect(find.text('Category Name'), findsOneWidget);
    expect(find.text('Popular Emojis'), findsOneWidget);
    expect(find.text('Save Category'), findsOneWidget);
  });
}
