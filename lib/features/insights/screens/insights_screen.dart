import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/features/export/providers/export_provider.dart';
import 'package:uangku/features/insights/providers/insights_provider.dart';
import 'package:uangku/features/insights/widgets/daily_spending_line_chart.dart';
import 'package:uangku/features/insights/widgets/monthly_comparison_card.dart';
import 'package:uangku/features/insights/widgets/spending_pie_chart.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final categorySpendingAsync = ref.watch(watchCategorySpendingProvider);
    final dailySpendingAsync = ref.watch(watchDailySpendingProvider);

    final exportState = ref.watch(exportNotifierProvider);

    // Listen for export state changes to show snackbars.
    ref.listen<ExportState>(exportNotifierProvider, (previous, next) {
      if (next == ExportState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data exported successfully!')),
        );
        ref.read(exportNotifierProvider.notifier).reset();
      } else if (next == ExportState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengekspor data. Silakan coba lagi.'),
          ),
        );
        ref.read(exportNotifierProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Insights'),
        elevation: 0,
        centerTitle: false,
        actions: [
          // Export to CSV
          IconButton(
            icon: exportState == ExportState.loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.file_download_outlined),
            tooltip: 'Export to CSV',
            onPressed: exportState == ExportState.loading
                ? null
                : () => ref
                      .read(exportNotifierProvider.notifier)
                      .exportAndShare(),
          ),
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
                    padding: const EdgeInsets.all(16),
                    child: SpendingPieChart(
                      spendingData: data,
                      totalSpending: totalSpending,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => const Center(
                  child: Text('Gagal memuat data. Silakan coba lagi.'),
                ),
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tren Pengeluaran Harian',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        DailySpendingLineChart(spendingData: data),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => const Center(
                  child: Text('Gagal memuat tren. Silakan coba lagi.'),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: ref
                  .watch(watchMonthlyComparisonProvider)
                  .when(
                    data: (comparison) =>
                        MonthlyComparisonCard(comparison: comparison),
                    loading: () => const SizedBox(
                      height: 150,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) =>
                        const Center(child: Text('Gagal memuat perbandingan.')),
                  ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
