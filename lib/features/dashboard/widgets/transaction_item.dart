import 'package:flutter/material.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
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
  final TransactionWithCategory transaction;

  /// The name of the wallet this transaction belongs to.
  final String walletName;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tx = transaction.transaction;
    final cat = transaction.category;

    final String iconCode = cat?.iconCode ?? 'swap_horiz';
    final String catName = cat?.name ?? 'Transfer';

    final categoryInfo = CategoryIconMapper.get(
      iconCode.isNotEmpty ? iconCode : catName,
    );
    final isIncome = tx.type == TransactionType.income;

    final amountColor = isIncome
        ? OceanFlowColors.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    final amountPrefix = isIncome ? '+' : '-';
    final formattedAmount =
        '$amountPrefix${CurrencyFormatter.format(tx.amount)}';

    final timeLabel = RelativeTimeFormatter.format(tx.date);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: categoryInfo.color.withValues(alpha: 0.12),
        child: Icon(categoryInfo.icon, color: categoryInfo.color, size: 20),
      ),
      title: Text(
        catName,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$walletName · $timeLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          if (tx.note.isNotEmpty)
            Text(
              tx.note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
        ],
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
