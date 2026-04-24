import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';

class NlpTransactionResult {
  final double amount;
  final TransactionType type;
  final Wallet? wallet;
  final Category? category;
  final Wallet? toWallet;
  final String note;
  final DateTime date;

  NlpTransactionResult({
    required this.amount,
    required this.type,
    this.wallet,
    this.category,
    this.toWallet,
    required this.note,
    required this.date,
  });

  factory NlpTransactionResult.fromJson(
    Map<String, dynamic> json,
    List<Wallet> wallets,
    List<Category> categories,
    Wallet defaultWallet,
  ) {
    // Amount
    double parsedAmount = 0.0;
    if (json['amount'] != null) {
      if (json['amount'] is num) {
        parsedAmount = (json['amount'] as num).toDouble();
      } else if (json['amount'] is String) {
        parsedAmount = double.tryParse(json['amount']) ?? 0.0;
      }
    }

    // Type
    TransactionType parsedType = TransactionType.expense;
    final typeStr = (json['type'] as String?)?.toLowerCase() ?? 'expense';
    if (typeStr == 'income') {
      parsedType = TransactionType.income;
    } else if (typeStr == 'transfer') {
      parsedType = TransactionType.transfer;
    }

    // Wallet (fuzzy match or default)
    Wallet? parsedWallet = defaultWallet;
    final walletStr = json['wallet'] as String?;
    if (walletStr != null && walletStr.isNotEmpty && wallets.isNotEmpty) {
      try {
        parsedWallet = wallets.firstWhere(
          (w) => w.name.toLowerCase().contains(walletStr.toLowerCase()) || 
                 walletStr.toLowerCase().contains(w.name.toLowerCase()),
          orElse: () => defaultWallet,
        );
      } catch (_) {}
    }

    // ToWallet (for transfer)
    Wallet? parsedToWallet;
    final toWalletStr = json['toWallet'] as String?;
    if (toWalletStr != null && toWalletStr.isNotEmpty && wallets.isNotEmpty) {
      try {
        parsedToWallet = wallets.firstWhere(
          (w) => w.name.toLowerCase().contains(toWalletStr.toLowerCase()) || 
                 toWalletStr.toLowerCase().contains(w.name.toLowerCase()),
          orElse: () => wallets.firstWhere((w) => w.id != parsedWallet?.id, orElse: () => wallets.first),
        );
      } catch (_) {}
    }

    // Category (fuzzy match)
    Category? parsedCategory;
    final categoryStr = json['category'] as String?;
    if (categoryStr != null && categoryStr.isNotEmpty && categories.isNotEmpty) {
      // Find matching type categories
      final matchingTypeCategories = categories.where((c) => c.type == parsedType).toList();
      final lookupList = matchingTypeCategories.isNotEmpty ? matchingTypeCategories : categories;
      
      try {
        parsedCategory = lookupList.firstWhere(
          (c) => c.name.toLowerCase().contains(categoryStr.toLowerCase()) || 
                 categoryStr.toLowerCase().contains(c.name.toLowerCase()),
          orElse: () => lookupList.first,
        );
      } catch (_) {}
    } else if (categories.isNotEmpty) {
      final matchingTypeCategories = categories.where((c) => c.type == parsedType).toList();
      if (matchingTypeCategories.isNotEmpty) {
         parsedCategory = matchingTypeCategories.first;
      }
    }

    // Date
    DateTime parsedDate = DateTime.now();
    if (json['date'] != null) {
      try {
        parsedDate = DateTime.parse(json['date']);
      } catch (_) {}
    }

    return NlpTransactionResult(
      amount: parsedAmount,
      type: parsedType,
      wallet: parsedWallet,
      toWallet: parsedToWallet,
      category: parsedCategory,
      note: json['note'] ?? '',
      date: parsedDate,
    );
  }
}
