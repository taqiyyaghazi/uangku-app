import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:uangku/data/models/category_spending.dart';

/// Interactive Pie Chart to display category spending distribution.
class SpendingPieChart extends StatefulWidget {
  final List<CategorySpending> spendingData;
  final double totalSpending;

  const SpendingPieChart({
    super.key,
    required this.spendingData,
    required this.totalSpending,
  });

  @override
  State<SpendingPieChart> createState() => _SpendingPieChartState();
}

class _SpendingPieChartState extends State<SpendingPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.spendingData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pie_chart_outline,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada data untuk periode ini.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 0.9, // Taller to accommodate legend comfortably
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend View
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: widget.spendingData.length,
              itemBuilder: (context, index) {
                final item = widget.spendingData[index];
                final isSelected = index == touchedIndex;
                final percentage =
                    (item.totalAmount / widget.totalSpending) * 100;
                final color = _parseColor(item.colorCode);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.categoryName,
                          style:
                              (isSelected
                                      ? Theme.of(context).textTheme.titleSmall
                                      : Theme.of(context).textTheme.bodyMedium)
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : null,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                  ),
                        ),
                      ),
                      Text(
                        'Rp ${item.totalAmount.toStringAsFixed(0)}',
                        style:
                            (isSelected
                                    ? Theme.of(context).textTheme.titleSmall
                                    : Theme.of(context).textTheme.bodyMedium)
                                ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : null,
                                ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(widget.spendingData.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final item = widget.spendingData[i];
      final percentage = (item.totalAmount / widget.totalSpending) * 100;

      return PieChartSectionData(
        color: _parseColor(item.colorCode),
        value: item.totalAmount,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    });
  }

  Color _parseColor(String colorCode) {
    if (colorCode.startsWith('#')) {
      final buffer = StringBuffer();
      if (colorCode.length == 7) buffer.write('ff'); // Add alpha if missing
      buffer.write(colorCode.replaceFirst('#', ''));
      final colorInt = int.tryParse(buffer.toString(), radix: 16);
      if (colorInt != null) {
        return Color(colorInt);
      }
    }
    return Colors.grey; // Fallback
  }
}
