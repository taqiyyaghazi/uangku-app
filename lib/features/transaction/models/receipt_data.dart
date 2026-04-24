import 'package:uangku/data/database.dart';

class ReceiptData {
  final double amount;
  final String notes;
  final DateTime date;
  final Category category;

  ReceiptData({
    required this.amount,
    required this.notes,
    required this.date,
    required this.category,
  });

  factory ReceiptData.fromJson(Map<String, dynamic> json, Category defaultCategory) {
    // Attempt to parse amount safely
    double parsedAmount = 0.0;
    if (json['amount'] != null) {
      if (json['amount'] is num) {
        parsedAmount = (json['amount'] as num).toDouble();
      } else if (json['amount'] is String) {
        parsedAmount = double.tryParse(json['amount']) ?? 0.0;
      }
    }

    // Parse date
    DateTime parsedDate = DateTime.now();
    if (json['date'] != null) {
      try {
        parsedDate = DateTime.parse(json['date']);
      } catch (_) {}
    }

    return ReceiptData(
      amount: parsedAmount,
      notes: json['store'] ?? json['notes'] ?? '',
      date: parsedDate,
      category: defaultCategory, // Category parsing might need fuzzy matching later
    );
  }
}
