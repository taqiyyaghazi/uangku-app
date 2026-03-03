import 'package:drift/drift.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/category_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase db;

  CategoryRepositoryImpl(this.db);

  @override
  Stream<List<Category>> watchAllCategories() {
    return (db.select(
      db.categories,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  @override
  Stream<List<Category>> watchCategoriesByType(TransactionType type) {
    return (db.select(db.categories)
          ..where((c) => c.type.equals(type.name))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  @override
  Future<int> createCategory(CategoriesCompanion category) {
    return db.into(db.categories).insert(category);
  }

  @override
  Future<bool> updateCategory(Category category) {
    return db.update(db.categories).replace(category);
  }

  @override
  Future<void> deleteCategory(int id) async {
    final canDelete = await canDeleteCategory(id);
    if (!canDelete) {
      throw Exception(
        'Category is currently in use by transactions and cannot be deleted.',
      );
    }
    await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
  }

  @override
  Future<bool> canDeleteCategory(int id) async {
    final usages = await (db.select(
      db.transactions,
    )..where((t) => t.categoryId.equals(id))).get();
    return usages.isEmpty;
  }
}
