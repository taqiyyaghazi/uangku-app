import 'dart:async';
import 'package:drift/drift.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/repositories/budget_repository.dart';
import 'package:uangku/features/sync/repository/sync_repository.dart';

class DriftBudgetRepository implements BudgetRepository {
  final AppDatabase _db;
  final MonitoringService _monitoring;
  final SyncRepository? _syncRepo;

  DriftBudgetRepository(this._db, this._monitoring, [this._syncRepo]);

  @override
  Stream<List<Budget>> watchAllBudgets() {
    const operation = 'watchAllBudgets';
    final startTime = DateTime.now();
    _monitoring.logInfo('START: $operation');

    return (_db.select(_db.budgets)
          ..orderBy([(t) => OrderingTerm.desc(t.periodMonth)]))
        .watch()
        .map((rows) {
          final durationMs = DateTime.now()
              .difference(startTime)
              .inMilliseconds;
          _monitoring.logInfo('SUCCESS: $operation', {
            'rows': rows.length,
            'durationMs': durationMs,
          });
          return rows;
        })
        .handleError((err, st) {
          _monitoring.logError('FAILURE: $operation', err, st);
          throw err;
        });
  }

  @override
  Stream<List<Budget>> watchBudgetsByPeriod(String periodMonth) {
    const operation = 'watchBudgetsByPeriod';
    final startTime = DateTime.now();
    _monitoring.logInfo('START: $operation', {'periodMonth': periodMonth});

    return (_db.select(_db.budgets)
          ..where((t) => t.periodMonth.equals(periodMonth)))
        .watch()
        .map((rows) {
          final durationMs = DateTime.now()
              .difference(startTime)
              .inMilliseconds;
          _monitoring.logInfo('SUCCESS: $operation', {
            'periodMonth': periodMonth,
            'rows': rows.length,
            'durationMs': durationMs,
          });
          return rows;
        })
        .handleError((err, st) {
          _monitoring.logError('FAILURE: $operation', err, st, {
            'periodMonth': periodMonth,
          });
          throw err;
        });
  }

  @override
  Future<void> setBudget({
    required int categoryId,
    required double amount,
    required String periodMonth,
  }) async {
    const operation = 'setBudget';
    final startTime = DateTime.now();
    _monitoring.logInfo('START: $operation', {
      'categoryId': categoryId,
      'amount': amount,
      'periodMonth': periodMonth,
    });

    try {
      await _db
          .into(_db.budgets)
          .insertOnConflictUpdate(
            BudgetsCompanion.insert(
              categoryId: categoryId,
              limitAmount: amount,
              periodMonth: periodMonth,
              updatedAt: Value(DateTime.now()),
            ),
          );

      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      _monitoring.logInfo('SUCCESS: $operation', {
        'categoryId': categoryId,
        'durationMs': durationMs,
      });

      unawaited(_syncRepo?.syncBudget(categoryId, periodMonth));
    } catch (e, st) {
      _monitoring.logError('FAILURE: $operation', e, st, {
        'categoryId': categoryId,
        'periodMonth': periodMonth,
      });
      rethrow;
    }
  }

  @override
  Future<void> deleteBudget(int categoryId, String periodMonth) async {
    const operation = 'deleteBudget';
    final startTime = DateTime.now();
    _monitoring.logInfo('START: $operation', {
      'categoryId': categoryId,
      'periodMonth': periodMonth,
    });

    try {
      await (_db.delete(_db.budgets)..where(
            (t) =>
                t.categoryId.equals(categoryId) &
                t.periodMonth.equals(periodMonth),
          ))
          .go();

      final durationMs = DateTime.now().difference(startTime).inMilliseconds;
      _monitoring.logInfo('SUCCESS: $operation', {
        'categoryId': categoryId,
        'durationMs': durationMs,
      });

      unawaited(_syncRepo?.deleteBudget(categoryId, periodMonth));
    } catch (e, st) {
      _monitoring.logError('FAILURE: $operation', e, st, {
        'categoryId': categoryId,
        'periodMonth': periodMonth,
      });
      rethrow;
    }
  }

  @override
  Future<Budget?> getBudget(int categoryId, String periodMonth) async {
    const operation = 'getBudget';
    _monitoring.logInfo('START: $operation', {
      'categoryId': categoryId,
      'periodMonth': periodMonth,
    });

    try {
      final result =
          await (_db.select(_db.budgets)..where(
                (t) =>
                    t.categoryId.equals(categoryId) &
                    t.periodMonth.equals(periodMonth),
              ))
              .getSingleOrNull();

      _monitoring.logInfo('SUCCESS: $operation', {'found': result != null});
      return result;
    } catch (e, st) {
      _monitoring.logError('FAILURE: $operation', e, st, {
        'categoryId': categoryId,
        'periodMonth': periodMonth,
      });
      rethrow;
    }
  }
}
