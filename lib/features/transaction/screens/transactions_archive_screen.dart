import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/features/transaction/logic/transaction_grouping_logic.dart';
import 'package:uangku/features/dashboard/widgets/transaction_item.dart';
import 'package:uangku/features/transaction/screens/multi_sliver_widget.dart';
import 'package:uangku/features/transaction/widgets/transaction_detail_sheet.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';
import 'package:uangku/shared/utils/wallet_icon_mapper.dart';
import 'package:uangku/shared/widgets/searchable_picker_sheet.dart';

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

  Future<void> _showWalletFilterPicker(
    BuildContext context,
    List<Wallet> wallets,
    int? selectedWalletId,
  ) async {
    final List<PickerItem<int>> items = [
      const PickerItem<int>(
        id: 0, // 0 for All Wallets
        name: 'All Wallets',
        icon: Icons.account_balance_wallet_outlined,
        color: OceanFlowColors.primary,
      ),
      ...wallets.map(
        (w) => PickerItem<int>(
          id: w.id,
          name: w.name,
          icon: WalletIconMapper.getIcon(w.icon),
          color: OceanFlowColors.primary,
          subtitle: CurrencyFormatter.format(w.balance),
        ),
      ),
    ];

    final result = await SearchablePickerSheet.show<int>(
      context,
      title: 'Filter by Wallet',
      items: items,
      selectedId: selectedWalletId ?? 0,
      searchPlaceholder: 'Search wallet name...',
    );

    if (result != null) {
      final walletId = result == 0 ? null : result;
      ref.read(selectedWalletFilterProvider.notifier).setFilter(walletId);

      ref.read(monitoringServiceProvider).logEvent(
        name: 'filter_wallet_changed',
        parameters: {
          'is_all_wallets': walletId == null ? 1 : 0,
          'wallet_id': walletId?.toString() ?? 'none',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch all transactions (descending order)
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final selectedWalletId = ref.watch(selectedWalletFilterProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Sticky App Bar with Search Field
          SliverAppBar(
            pinned: true,
            title: const Text('All Transactions'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                  walletsAsync.when(
                    data: (wallets) {
                      Wallet? selectedWallet;
                      if (selectedWalletId != null) {
                        try {
                          selectedWallet = wallets.firstWhere(
                            (w) => w.id == selectedWalletId,
                          );
                        } catch (_) {
                          selectedWallet = null;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ActionChip(
                            avatar: Icon(
                              selectedWallet == null
                                  ? Icons.account_balance_wallet_outlined
                                  : WalletIconMapper.getIcon(
                                    selectedWallet.icon,
                                  ),
                              size: 18,
                              color: OceanFlowColors.primary,
                            ),
                            label: Text(selectedWallet?.name ?? 'All Wallets'),
                            onPressed:
                                () => _showWalletFilterPicker(
                                  context,
                                  wallets,
                                  selectedWalletId,
                                ),
                            side: BorderSide.none,
                            backgroundColor: OceanFlowColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            labelStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: OceanFlowColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox(height: 40),
                    error: (error, stack) => const SizedBox(height: 40),
                  ),
                ],
              ),
            ),
          ),

          // Content Layer
          transactionsAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                if (selectedWalletId != null) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('Belum ada transaksi di wallet ini.'),
                    ),
                  );
                }
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
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: TransactionItem(
                                  key: ValueKey(transaction.transaction.id),
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
                                ),
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
