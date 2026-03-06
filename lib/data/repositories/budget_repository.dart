import 'package:uangku/data/database.dart';

/// Repository interface (contract) for Budget data access.
abstract class BudgetRepository {
  /// Returns a reactive stream of all budgets.
  Stream<List<Budget>> watchAllBudgets();

  /// Returns a reactive stream of budgets for a specific [periodMonth].
  Stream<List<Budget>> watchBudgetsByPeriod(String periodMonth);

  /// Sets or updates a budget for a category and period.
  Future<void> setBudget({
    required int categoryId,
    required double amount,
    required String periodMonth,
  });

  /// Deletes a budget.
  Future<void> deleteBudget(int categoryId, String periodMonth);

  /// Returns a single budget if it exists.
  Future<Budget?> getBudget(int categoryId, String periodMonth);
}
