import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/features/insights/providers/insights_provider.dart';
import 'package:uangku/features/insights/widgets/daily_spending_line_chart.dart';
import 'package:uangku/features/insights/widgets/spending_pie_chart.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final categorySpendingAsync = ref.watch(watchCategorySpendingProvider);
    final dailySpendingAsync = ref.watch(watchDailySpendingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          // Month Selector
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => _selectMonth(context, ref, selectedMonth),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatMonth(selectedMonth),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pengeluaran Berdasarkan Kategori',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: categorySpendingAsync.when(
                data: (data) {
                  final totalSpending = data.fold<double>(
                    0.0,
                    (sum, item) => sum + item.totalAmount,
                  );

                  return Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardTheme.color ??
                          Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: SpendingPieChart(
                      spendingData: data,
                      totalSpending: totalSpending,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Gagal memuat data:\n$err')),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: dailySpendingAsync.when(
                data: (data) {
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardTheme.color ??
                          Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 8,
                    ),
                    child: DailySpendingLineChart(spendingData: data),
                  );
                },
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) =>
                    Center(child: Text('Gagal memuat tren:\n$err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectMonth(
    BuildContext context,
    WidgetRef ref,
    DateTime initialDate,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: OceanFlowColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Create a new DateTime set strictly to the first day of the picked month
      final monthSelection = DateTime(picked.year, picked.month, 1);
      ref.read(selectedMonthProvider.notifier).setMonth(monthSelection);
    }
  }
}
