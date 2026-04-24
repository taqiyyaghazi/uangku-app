import 'package:flutter/material.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/features/transaction/models/nlp_transaction_result.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class NlpConfirmationDialog extends StatelessWidget {
  final NlpTransactionResult result;

  const NlpConfirmationDialog({super.key, required this.result});

  static Future<bool?> show(BuildContext context, NlpTransactionResult result) {
    return showDialog<bool>(
      context: context,
      builder: (context) => NlpConfirmationDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountFormatted = CurrencyFormatter.format(result.amount);
    final walletName = result.wallet?.name ?? 'Unknown Wallet';
    final typeName = result.type.name.toLowerCase();
    
    String summary;
    if (typeName == 'transfer' && result.toWallet != null) {
      summary = 'Transfer $amountFormatted from $walletName to ${result.toWallet!.name}';
    } else if (typeName == 'expense') {
      summary = 'Expense $amountFormatted for ${result.note.isNotEmpty ? result.note : result.category?.name ?? "something"} using $walletName';
    } else {
      summary = 'Income $amountFormatted for ${result.note.isNotEmpty ? result.note : result.category?.name ?? "something"} to $walletName';
    }

    final dateStr = DateFormat('EEE, d MMM yyyy').format(result.date);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.auto_awesome, color: OceanFlowColors.primary),
          const SizedBox(width: 8),
          const Text('Confirm Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(summary, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text('Date: $dateStr', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          if (result.category != null && typeName != 'transfer') 
            Text('Category: ${result.category!.name}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),
          const Text('Is this correct?', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Edit'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Save'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
