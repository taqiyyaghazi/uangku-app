import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/features/transaction/logic/transaction_grouping_logic.dart';
import 'package:uangku/features/dashboard/widgets/transaction_item.dart';
import 'package:uangku/features/transaction/screens/multi_sliver_widget.dart';
import 'package:uangku/features/transaction/widgets/transaction_detail_sheet.dart';

/// Screen showcasing the full transaction history, grouped by month/year.
class TransactionsArchiveScreen extends ConsumerStatefulWidget {
  const TransactionsArchiveScreen({super.key});

  @override
  ConsumerState<TransactionsArchiveScreen> createState() =>
      _TransactionsArchiveScreenState();
}

class _TransactionsArchiveScreenState
    extends ConsumerState<TransactionsArchiveScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // 1. Watch all transactions (descending order)
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final walletsAsync = ref.watch(walletsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Sticky App Bar with Search Field
          SliverAppBar(
            pinned: true,
            title: const Text('All Transactions'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: CupertinoSearchTextField(
                  placeholder: 'Search notes or categories...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),

          // Content Layer
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('Riwayat kosong. Mulai mencatat hari ini!'),
                  ),
                );
              }

              // Apply Search Filter (Pure Logic)
              final filtered = TransactionGroupingLogic.filterBySearchQuery(
                transactions,
                _searchQuery,
              );

              if (filtered.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text('No transactions match your search.'),
                  ),
                );
              }

              // Group by Month/Year (Pure Logic)
              final grouped = TransactionGroupingLogic.groupByMonth(filtered);

              return walletsAsync.when(
                data: (wallets) {
                  // Helper to resolve wallet name
                  String getWalletName(int walletId) {
                    try {
                      return wallets.firstWhere((w) => w.id == walletId).name;
                    } catch (_) {
                      return 'Unknown Wallet';
                    }
                  }

                  // Render using SliverMainAxisGroup for Sticky Headers per group
                  return MultiSliverWidget(
                    slivers: grouped.keys.map((monthKey) {
                      final monthTransactions = grouped[monthKey]!;
                      return SliverMainAxisGroup(
                        slivers: [
                          // 1. The Sticky Header for the Month
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _MonthHeaderDelegate(
                              monthKey: monthKey,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              textColor: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          // 2. The Transactions for that Month
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              itemIndex,
                            ) {
                              final transaction = monthTransactions[itemIndex];
                              final walletName = getWalletName(
                                transaction.transaction.walletId,
                              );
                              return TransactionItem(
                                transaction: transaction,
                                walletName: walletName,
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        TransactionDetailSheet(
                                          transaction: transaction,
                                          walletName: walletName,
                                        ),
                                  );
                                },
                              );
                            }, childCount: monthTransactions.length),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => SliverFillRemaining(
                  child: Center(child: Text('Error loading wallets: \$e')),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => SliverFillRemaining(
              child: Center(child: Text('Error loading transactions: \$e')),
            ),
          ),
        ],
      ),
    );
  }
}

/// A custom delegate for sticky sliver headers showing the month/year string.
class _MonthHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String monthKey;
  final Color backgroundColor;
  final Color textColor;

  _MonthHeaderDelegate({
    required this.monthKey,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Text(
        monthKey,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 36.0;

  @override
  double get minExtent => 36.0;

  @override
  bool shouldRebuild(covariant _MonthHeaderDelegate oldDelegate) {
    return oldDelegate.monthKey != monthKey ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.textColor != textColor;
  }
}
