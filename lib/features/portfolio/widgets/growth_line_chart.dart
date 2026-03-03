import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';

/// A line chart showing investment net worth growth over time.
///
/// Displays [FlSpot] points representing the history of investment snapshots.
/// Includes support for a gradient area below the line and a Touch tooltip.
class GrowthLineChart extends StatelessWidget {
  const GrowthLineChart({
    super.key,
    required this.spots,
    required this.minDate,
    required this.maxDate,
  });

  /// The points to plot (X = days offset, Y = Total Value).
  final List<FlSpot> spots;

  /// The starting date to compute actual dates from the X offset.
  final DateTime minDate;

  /// The ending date to compute actual dates from the X offset.
  final DateTime maxDate;

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'No investment data available',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    // Only one point? Add a duplicate slightly before so it draws a continuous flat line
    final displaySpots = spots.length == 1
        ? [
            FlSpot(
              spots.first.x - 1 < 0 ? 0 : spots.first.x - 1,
              spots.first.y,
            ),
            spots.first,
          ]
        : spots;

    final maxY = displaySpots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final minY = displaySpots.map((s) => s.y).reduce((a, b) => a < b ? a : b);

    // Add 10% padding so the line doesn't hit the absolute top/bottom
    final yRange = (maxY - minY).abs();
    final paddedMaxY = maxY + (yRange == 0 ? maxY * 0.1 : yRange * 0.1);
    final paddedMinY = (minY - (yRange == 0 ? minY * 0.1 : yRange * 0.1)).clamp(
      0.0,
      double.infinity,
    );

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          // ── Tooltip config ──────────────────────────────────
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  OceanFlowColors.neutral.withValues(alpha: 0.9),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((touchedSpot) {
                  return LineTooltipItem(
                    CurrencyFormatter.format(touchedSpot.y),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),

          // ── Axes and Grid ───────────────────────────────────
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (paddedMaxY - paddedMinY) / 4 > 0
                ? (paddedMaxY - paddedMinY) / 4
                : 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            // Left Axis (Values) - Hidden to keep UI clean, we use tooltips
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            // Bottom Axis (Months/Dates roughly)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: displaySpots.last.x / 4 > 0
                    ? displaySpots.last.x / 4
                    : 1,
                getTitlesWidget: (value, meta) {
                  // Don't show the last exact label if it's the edge to prevent clipping
                  if (value == meta.max || value == meta.min) {
                    return const SizedBox.shrink();
                  }

                  // Convert generic X value (days offset) back to an approximate month label
                  final labelDate = minDate.add(Duration(days: value.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _monthAbbreviation(labelDate.month),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),

          // ── Line config ─────────────────────────────────────
          minX: displaySpots.first.x,
          maxX: displaySpots.last.x,
          minY: paddedMinY,
          maxY: paddedMaxY,

          lineBarsData: [
            LineChartBarData(
              spots: displaySpots,
              isCurved: true,
              color: OceanFlowColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: false,
              ), // Hide dots by default, show on hover
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    OceanFlowColors.primary.withValues(alpha: 0.3),
                    OceanFlowColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthAbbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
