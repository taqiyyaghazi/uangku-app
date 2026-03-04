/// Represents aggregated spending for a specific day.
class DailySpending {
  final DateTime date;
  final double totalAmount;

  DailySpending({required this.date, required this.totalAmount});

  @override
  String toString() => 'DailySpending(date: $date, totalAmount: $totalAmount)';
}
