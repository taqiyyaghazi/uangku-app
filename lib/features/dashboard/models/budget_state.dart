/// Holds the computed daily budget snapshot.
///
/// This is a pure data class — no state management, no I/O.
class BudgetState {
  const BudgetState({
    required this.monthlyLimit,
    required this.totalSpentThisMonth,
    required this.spentToday,
    required this.dailyAllowance,
    required this.remainingDays,
    required this.remainingBudget,
    required this.progressRatio,
    required this.isOverspent,
    this.correctionMessage,
  });

  /// The monthly spending limit set by the user.
  final double monthlyLimit;

  /// Total expenses recorded this calendar month.
  final double totalSpentThisMonth;

  /// Total expenses recorded today.
  final double spentToday;

  /// How much the user can spend per remaining day:
  /// `(monthlyLimit - totalSpentThisMonth) / remainingDays`
  final double dailyAllowance;

  /// Number of remaining days in the month (including today).
  final int remainingDays;

  /// `monthlyLimit - totalSpentThisMonth`
  final double remainingBudget;

  /// `spentToday / dailyAllowance` — clamped to [0, 2] for display.
  /// Values > 1.0 mean overspending.
  final double progressRatio;

  /// Whether today's spending exceeds the daily allowance.
  final bool isOverspent;

  /// Human-readable correction message when overspent.
  /// e.g. "Overspent Rp 50.000 today. Tomorrow's budget adjusted to Rp 120.000."
  final String? correctionMessage;
}
