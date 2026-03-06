import 'dart:async';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/category_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/sync/repository/sync_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase db;
  final SyncRepository? _syncRepo;

  CategoryRepositoryImpl(this.db, [this._syncRepo]);

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
  Future<int> createCategory(CategoriesCompanion category) async {
    final name = category.name.value;
    developer.log(
      'Creating category: $name',
      name: 'CategoryRepositoryImpl.createCategory',
    );
    final startTime = DateTime.now();
    try {
      final id = await db.into(db.categories).insert(category);
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      developer.log(
        'Successfully created category: $name (ID: $id)',
        name: 'CategoryRepositoryImpl.createCategory',
        error: {'duration': duration},
      );

      unawaited(_syncRepo?.syncCategory(id));

      return id;
    } catch (e, st) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      developer.log(
        'Failed to create category: $name',
        name: 'CategoryRepositoryImpl.createCategory',
        error: {'error': e.toString(), 'duration': duration},
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<bool> updateCategory(Category category) async {
    developer.log(
      'Updating category: ${category.name} (ID: ${category.id})',
      name: 'CategoryRepositoryImpl.updateCategory',
    );
    final startTime = DateTime.now();
    try {
      final success = await db.update(db.categories).replace(category);
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      developer.log(
        'Successfully updated category: ${category.name}',
        name: 'CategoryRepositoryImpl.updateCategory',
        error: {'duration': duration, 'success': success},
      );

      unawaited(_syncRepo?.syncCategory(category.id));

      return success;
    } catch (e, st) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      developer.log(
        'Failed to update category: ${category.name}',
        name: 'CategoryRepositoryImpl.updateCategory',
        error: {'error': e.toString(), 'duration': duration},
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    developer.log(
      'Attempting to delete category (ID: $id)',
      name: 'CategoryRepositoryImpl.deleteCategory',
    );
    final startTime = DateTime.now();
    try {
      final canDelete = await canDeleteCategory(id);
      if (!canDelete) {
        throw Exception(
          'Category is currently in use by transactions and cannot be deleted.',
        );
      }
      await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();

      final duration = DateTime.now().difference(startTime).inMilliseconds;
      developer.log(
        'Successfully deleted category (ID: $id)',
        name: 'CategoryRepositoryImpl.deleteCategory',
        error: {'duration': duration},
      );

      unawaited(_syncRepo?.deleteCategory(id));
    } catch (e, st) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      developer.log(
        'Failed to delete category (ID: $id)',
        name: 'CategoryRepositoryImpl.deleteCategory',
        error: {'error': e.toString(), 'duration': duration},
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<bool> canDeleteCategory(int id) async {
    final usages =
        await (db.select(db.transactions)
              ..where((t) => t.categoryId.equals(id))
              ..limit(1))
            .get();
    return usages.isEmpty;
  }
}
