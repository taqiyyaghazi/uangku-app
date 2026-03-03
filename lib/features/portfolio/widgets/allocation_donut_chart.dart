import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';

/// A donut chart showing the distribution of asset types.
///
/// Uses [PieChart] from fl_chart to render a clustered grouping
/// of Cash, Bank, and Investment wallets. Includes a custom legend.
class AllocationDonutChart extends StatelessWidget {
  const AllocationDonutChart({
    super.key,
    required this.sections,
    required this.totalNetWorth,
  });

  /// The slices of the donut chart (provided by walletAllocationProvider).
  final List<PieChartSectionData> sections;

  /// The total sum of all assets (displayed in the center).
  final double totalNetWorth;

  @override
  Widget build(BuildContext context) {
    // Determine labels and colors for the legend based on the sections passed.
    // We expect sections.color to match OceanFlowTheme.
    final theme = Theme.of(context);

    if (sections.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No assets to display',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(enabled: true),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 70, // Makes it a donut
                  sections: sections,
                ),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
              // Center Text (Total Net Worth)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Net Worth',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(totalNetWorth),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Custom Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: sections.map((section) {
            return _LegendItem(
              color: section.color,
              label: section.title,
              value: section.value,
              percentage: (section.value / totalNetWorth) * 100,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.percentage,
  });

  final Color color;
  final String label;
  final double value;
  final double percentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label (${percentage.toStringAsFixed(1)}%)',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              CurrencyFormatter.format(value),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
