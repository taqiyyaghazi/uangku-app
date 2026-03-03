import 'dart:developer' as developer;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/wallets_table.dart';

/// Represents a slice of the allocation donut chart.
class WalletAllocationData {
  final WalletType type;
  final double amount;
  final double percentage;
  final Color color;

  const WalletAllocationData({
    required this.type,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

/// Aggregates all wallets into allocations by [WalletType].
final walletAllocationProvider = Provider<List<WalletAllocationData>>((ref) {
  final walletsAsync = ref.watch(walletsProvider);

  return walletsAsync.maybeWhen(
    data: (wallets) {
      if (wallets.isEmpty) return [];

      double total = 0;
      final typeAmounts = <WalletType, double>{
        WalletType.cash: 0,
        WalletType.bank: 0,

        WalletType.investment: 0,
      };

      for (final wallet in wallets) {
        if (wallet.balance > 0) {
          typeAmounts[wallet.type] =
              (typeAmounts[wallet.type] ?? 0) + wallet.balance;
          total += wallet.balance;
        }
      }

      if (total == 0) return [];

      return typeAmounts.entries.where((e) => e.value > 0).map((e) {
        Color color;
        switch (e.key) {
          case WalletType.investment:
            color = OceanFlowColors.primary; // Teal

          case WalletType.bank:
            color = OceanFlowColors.primaryLight; // Light Teal

          case WalletType.cash:
            color = OceanFlowColors.neutral; // Grey block
        }

        return WalletAllocationData(
          type: e.key,
          amount: e.value,
          percentage: e.value / total,
          color: color,
        );
      }).toList()..sort((a, b) => b.amount.compareTo(a.amount));
    },
    orElse: () => [],
  );
});

/// Computes the net worth growth timeline (last 6 months) for the line chart.
///
/// Converts [InvestmentSnapshot]s into [FlSpot]s where:
/// X = days since the first snapshot in the 6-month window
/// Y = total investment value on that day
final netWorthGrowthProvider = FutureProvider<List<FlSpot>>((ref) async {
  final walletsAsync = ref.watch(walletsProvider);
  final repo = ref.watch(investmentRepositoryProvider);

  final List<Wallet> wallets = walletsAsync.asData?.value ?? [];
  final invWallets = wallets
      .where((w) => w.type == WalletType.investment)
      .toList();

  if (invWallets.isEmpty) return [];

  // 1. Get all snapshots representing the last 6 months.
  // For simplicity since watchSnapshotsByWallet returns a stream, we just read the first event.
  // In a real production app with massive data, we'd query this directly via a generic DAO method
  // `getSnapshotsSince(DateTime)`. Let's build the snapshot map locally.
  final earliestDate = DateTime.now().subtract(const Duration(days: 180));

  Map<int, List<InvestmentSnapshot>> allSnapshots = {};
  for (final wallet in invWallets) {
    try {
      final stream = repo.watchSnapshotsByWallet(wallet.id);
      final list = await stream.first;
      allSnapshots[wallet.id] = list
          .where((s) => s.snapshotDate.isAfter(earliestDate))
          .toList();
    } catch (e, st) {
      developer.log(
        'Failed to fetch snapshots for wallet ${wallet.id}',
        name: 'netWorthGrowthProvider',
        error: e,
        stackTrace: st,
      );
    }
  }

  // 2. Generate a daily timeline.
  // X-axis: days offset. Y-axis: sum of latest snapshot value up to that day for each wallet.
  List<FlSpot> spots = [];

  // Find the absolute first snapshot date across all wallets within 6 months
  DateTime? firstOverallDate;
  for (final list in allSnapshots.values) {
    if (list.isNotEmpty) {
      final lastInList = list.last.snapshotDate; // Since it's desc ordered
      if (firstOverallDate == null || lastInList.isBefore(firstOverallDate)) {
        firstOverallDate = lastInList;
      }
    }
  }

  if (firstOverallDate == null) {
    // No snapshots in the last 6 months, just use current wallet balances
    // to plot a single point today.
    double totalNow = invWallets.fold(0, (sum, w) => sum + w.balance);
    return [FlSpot(0, totalNow)];
  }

  // Generate spots grouped by week (roughly) to prevent overcrowding the chart
  // Instead of every single day, let's take weekly snapshots.
  final now = DateTime.now();
  final int totalDays = now.difference(firstOverallDate).inDays;

  // If less than a week, plot daily, else weekly
  int stepDays = totalDays > 30 ? 7 : 1;
  if (totalDays == 0) stepDays = 1;

  for (int dayOffset = 0; dayOffset <= totalDays; dayOffset += stepDays) {
    final currentEvalDate = firstOverallDate.add(Duration(days: dayOffset));

    double sumAtDate = 0;
    for (final wallet in invWallets) {
      final snapshots = allSnapshots[wallet.id] ?? [];
      // Find the latest snapshot BEFORE OR ON currentEvalDate.
      // Snapshots are desc ordered (newest first).
      final applicableSnapshot = snapshots.firstWhere(
        (s) => s.snapshotDate.isBefore(
          currentEvalDate.add(const Duration(days: 1)),
        ),
        orElse: () => InvestmentSnapshot(
          id: -1,
          walletId: wallet.id,
          totalValue: 0,
          snapshotDate: DateTime.now(),
        ),
      );

      sumAtDate += applicableSnapshot.totalValue;
    }

    spots.add(FlSpot(dayOffset.toDouble(), sumAtDate));
  }

  // Always include today's actual current balance at the very end
  double totalToday = invWallets.fold(0, (sum, w) => sum + w.balance);
  if (spots.isEmpty || spots.last.x != totalDays.toDouble()) {
    spots.add(FlSpot(totalDays.toDouble(), totalToday));
  } else {
    spots.last = FlSpot(totalDays.toDouble(), totalToday);
  }

  return spots;
});
