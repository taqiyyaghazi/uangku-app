import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/features/dashboard/widgets/transaction_item.dart';
import 'package:uangku/features/transaction/screens/transaction_detail_sheet.dart';
import 'package:uangku/features/transaction/screens/transactions_archive_screen.dart';

/// Displays the "Recent Activity" section on the Dashboard.
///
/// Watches [recentTransactionsProvider] and [walletsProvider] to reactively
/// show the 10 most recent transactions. Shows an empty state when no
/// transactions exist.
class RecentActivitySection extends ConsumerWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);
    final walletsAsync = ref.watch(walletsProvider);
    final theme = Theme.of(context);

    return SliverToBoxAdapter(
      child: transactionsAsync.when(
        loading: () => const SizedBox(height: 80),
        error: (_, _) => const SizedBox.shrink(),
        data: (transactions) {
          // Build a walletId → walletName lookup map.
          final walletMap = <int, String>{};
          final wallets = walletsAsync.value ?? [];
          for (final w in wallets) {
            walletMap[w.id] = w.name;
          }

          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section Header ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Activity',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TransactionsArchiveScreen(),
                            ),
                          );
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),

                // ── Empty State ─────────────────────────────────────
                if (transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 32,
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada transaksi. Tap + untuk memulai.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Transaction List ────────────────────────────────
                if (transactions.isNotEmpty)
                  ...transactions.map((tx) {
                    final name =
                        walletMap[tx.transaction.walletId] ?? 'Unknown';
                    return TransactionItem(
                      transaction: tx,
                      walletName: name,
                      onTap: () => TransactionDetailSheet.show(
                        context,
                        transaction: tx,
                        walletName: name,
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
