import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';

/// Repository for managing custom transaction categories.
abstract class CategoryRepository {
  /// Returns a reactive stream of all categories, sorted by default ordering.
  Stream<List<Category>> watchAllCategories();

  /// Returns a reactive stream of categories filtered by a specific type.
  Stream<List<Category>> watchCategoriesByType(TransactionType type);

  /// Creates a new category and returns its generated ID.
  Future<int> createCategory(CategoriesCompanion category);

  /// Updates an existing category.
  Future<bool> updateCategory(Category category);

  /// Deletes a category if it is not in use by any transactions.
  /// Throws an exception if deletion is prevented.
  Future<void> deleteCategory(int id);

  /// Checks if a category can be safely deleted (has no related transactions).
  Future<bool> canDeleteCategory(int id);
}
