import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/category_repository.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/features/sync/repository/sync_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase db;
  final SyncRepository? _syncRepo;
  final MonitoringService _monitoring;

  CategoryRepositoryImpl(this.db, this._monitoring, [this._syncRepo]);

  @override
  Stream<List<Category>> watchAllCategories() {
    const operation = 'watchAllCategories';
    final startTime = DateTime.now();
    _monitoring.logInfo('START: $operation');

    return (db.select(db.categories)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) {
          final successTime = DateTime.now();
          final durationMs = successTime.difference(startTime).inMilliseconds;
          _monitoring.logInfo('SUCCESS: $operation', {
            'rows': rows.length,
            'durationMs': durationMs,
          });
          return rows;
        })
        .handleError((err, stack) {
          _monitoring.logError('FAILURE: $operation', err, stack);
          throw err;
        });
  }

  @override
  Stream<List<Category>> watchCategoriesByType(TransactionType type) {
    const operation = 'watchCategoriesByType';
    final startTime = DateTime.now();
    _monitoring.logInfo('START: $operation', {'type': type.name});

    return (db.select(db.categories)
          ..where((c) => c.type.equals(type.name))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) {
          final successTime = DateTime.now();
          final durationMs = successTime.difference(startTime).inMilliseconds;
          _monitoring.logInfo('SUCCESS: $operation', {
            'type': type.name,
            'rows': rows.length,
            'durationMs': durationMs,
          });
          return rows;
        })
        .handleError((err, stack) {
          _monitoring.logError('FAILURE: $operation', err, stack, {
            'type': type.name,
          });
          throw err;
        });
  }

  @override
  Future<int> createCategory(CategoriesCompanion category) async {
    const operation = 'createCategory';
    final startTime = DateTime.now();
    try {
      _monitoring.logInfo('START: $operation');
      final id = await db.into(db.categories).insert(category);
      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      _monitoring.logInfo('SUCCESS: $operation', {
        'id': id,
        'durationMs': durationMs,
      });

      unawaited(_syncRepo?.syncCategory(id));

      return id;
    } catch (e, st) {
      _monitoring.logError('FAILURE: $operation', e, st);
      rethrow;
    }
  }

  @override
  Future<bool> updateCategory(Category category) async {
    const operation = 'updateCategory';
    final startTime = DateTime.now();
    try {
      _monitoring.logInfo('START: $operation', {'id': category.id});
      final success = await db.update(db.categories).replace(category);
      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      _monitoring.logInfo('SUCCESS: $operation', {
        'id': category.id,
        'durationMs': durationMs,
      });

      unawaited(_syncRepo?.syncCategory(category.id));

      return success;
    } catch (e, st) {
      _monitoring.logError('FAILURE: $operation', e, st, {'id': category.id});
      rethrow;
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    const operation = 'deleteCategory';
    final startTime = DateTime.now();
    try {
      _monitoring.logInfo('START: $operation', {'id': id});
      final canDelete = await canDeleteCategory(id);
      if (!canDelete) {
        throw Exception(
          'Category is currently in use by transactions and cannot be deleted.',
        );
      }
      await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();

      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      _monitoring.logInfo('SUCCESS: $operation', {
        'id': id,
        'durationMs': durationMs,
      });

      unawaited(_syncRepo?.deleteCategory(id));
    } catch (e, st) {
      _monitoring.logError('FAILURE: $operation', e, st, {'id': id});
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
