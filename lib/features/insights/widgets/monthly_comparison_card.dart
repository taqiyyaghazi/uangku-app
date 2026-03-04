import 'package:flutter/material.dart';
import 'package:uangku/data/models/monthly_comparison.dart';
import 'package:uangku/features/insights/logic/comparison_helper.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';

class MonthlyComparisonCard extends StatelessWidget {
  final MonthlyComparison comparison;

  const MonthlyComparisonCard({super.key, required this.comparison});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perbandingan Bulan Ini',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ComparisonRow(
              label: 'Pendapatan',
              current: comparison.current.totalIncome,
              delta: comparison.incomeDelta,
              isPositiveGood: true,
            ),
            const Divider(height: 24),
            _ComparisonRow(
              label: 'Pengeluaran',
              current: comparison.current.totalExpenses,
              delta: comparison.expenseDelta,
              isPositiveGood: false,
            ),
            const SizedBox(height: 20),
            _SavingsRateInsight(
              currentRate: comparison.current.savingsRate,
              previousRate: comparison.previous.savingsRate,
              expenseDelta: comparison.expenseDelta,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final double current;
  final double delta;
  final bool isPositiveGood;

  const _ComparisonRow({
    required this.label,
    required this.current,
    required this.delta,
    required this.isPositiveGood,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine color based on delta and its meaning
    Color deltaColor;
    IconData deltaIcon;

    if (delta == 0) {
      deltaColor = colorScheme.onSurfaceVariant;
      deltaIcon = Icons.remove;
    } else if ((delta > 0 && isPositiveGood) ||
        (delta < 0 && !isPositiveGood)) {
      deltaColor = Colors.teal; // Success/Good
      deltaIcon = delta > 0 ? Icons.arrow_upward : Icons.arrow_downward;
    } else {
      deltaColor = Colors.orange; // Warning/Alert
      deltaIcon = delta > 0 ? Icons.arrow_upward : Icons.arrow_downward;
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.format(current),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: deltaColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(deltaIcon, size: 14, color: deltaColor),
              const SizedBox(width: 4),
              Text(
                '${delta.abs().toStringAsFixed(1)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: deltaColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SavingsRateInsight extends StatelessWidget {
  final double currentRate;
  final double previousRate;
  final double expenseDelta;

  const _SavingsRateInsight({
    required this.currentRate,
    required this.previousRate,
    required this.expenseDelta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final savingsRatePercentage = (currentRate * 100).toStringAsFixed(1);
    final message = ComparisonHelper.getExpenseMessage(expenseDelta);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rasio Tabungan',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$savingsRatePercentage%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Simple progress bar for savings rate
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: currentRate.clamp(0.0, 1.0),
              backgroundColor: colorScheme.outlineVariant.withValues(
                alpha: 0.3,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
