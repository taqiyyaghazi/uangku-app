import 'package:flutter/material.dart';

import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/shared/utils/category_icon_mapper.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';
import 'package:uangku/shared/utils/relative_time_formatter.dart';

/// Displays a single transaction row in the Recent Activity list.
///
/// Shows category icon, category name, wallet name + timestamp,
/// and the formatted amount color-coded by transaction type.
///
/// This is a pure presentation widget — no I/O or state management.
class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.transaction,
    required this.walletName,
    this.onTap,
  });

  /// The transaction data to display.
  final Transaction transaction;

  /// The name of the wallet this transaction belongs to.
  final String walletName;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryInfo = CategoryIconMapper.get(transaction.category);
    final isIncome = transaction.type == TransactionType.income;

    final amountColor = isIncome
        ? OceanFlowColors.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    final amountPrefix = isIncome ? '+' : '-';
    final formattedAmount =
        '$amountPrefix${CurrencyFormatter.format(transaction.amount)}';

    final timeLabel = RelativeTimeFormatter.format(transaction.date);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: categoryInfo.color.withValues(alpha: 0.12),
        child: Icon(categoryInfo.icon, color: categoryInfo.color, size: 20),
      ),
      title: Text(
        transaction.category,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '$walletName · $timeLabel',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      trailing: Text(
        formattedAmount,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: amountColor,
        ),
      ),
    );
  }
}
