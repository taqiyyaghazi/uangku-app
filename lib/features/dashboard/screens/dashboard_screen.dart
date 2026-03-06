import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/core/config/app_config.dart';
import 'package:uangku/core/constants/app_constants.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/features/auth/state/auth_provider.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/features/dashboard/widgets/daily_breath_bar.dart';
import 'package:uangku/features/dashboard/widgets/dashboard_header.dart';
import 'package:uangku/features/dashboard/widgets/recent_activity_section.dart';
import 'package:uangku/features/dashboard/widgets/wallet_form_sheet.dart';
import 'package:uangku/features/dashboard/widgets/wallet_grid.dart';
import 'package:uangku/features/sync/state/sync_status_provider.dart';
import 'package:uangku/features/transaction/widgets/quick_entry_sheet.dart';

/// The main dashboard screen displaying the wallet grid and total balance.
///
/// Consumes [walletsProvider] for reactive wallet data.
/// Consumes [dailyBreathProvider] for the budget progress bar.
/// Uses [walletRepositoryProvider] for create/update operations.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);
    final syncStatus = ref.watch(syncStatusProvider);

    // Listen for auth state changes to trigger restoration.
    ref.listen(authStateProvider, (previous, next) {
      if (next.value != null && (previous == null || previous.value == null)) {
        ref.read(syncStatusProvider.notifier).restoreDataIfNeeded();
      }
    });

    // Listen for sync completion or error to show feedback.
    ref.listen(syncStatusProvider, (previous, next) {
      if (next.status == SyncStatus.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome back! Your data has been restored.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(syncStatusProvider.notifier).reset();
      } else if (next.status == SyncStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message ?? 'Failed to restore data'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(syncStatusProvider.notifier).reset();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          walletsAsync.when(
            data: (wallets) => _buildContent(context, ref, wallets),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load wallets',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(walletsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

          // --- Dev Environment Banner ---
          if (AppConfig.isDev)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: -30,
              child: Transform.rotate(
                angle: 0.785, // 45 degrees
                child: Container(
                  width: 120,
                  color: Colors.red.withValues(alpha: 0.8),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Center(
                    child: Text(
                      'DEV',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // --- Sync Loading Overlay ---
          if (syncStatus.status == SyncStatus.syncing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 24),
                      Text(
                        syncStatus.message ?? 'Restoring your data...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This will only take a moment',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => QuickEntrySheet.show(context),
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Wallet> wallets,
  ) {
    final totalBalance = wallets.fold(0.0, (sum, w) => sum + w.balance);
    final breathAsync = ref.watch(dailyBreathProvider);

    return CustomScrollView(
      slivers: [
        // ── Total Balance Header ───────────────────────────────────
        SliverToBoxAdapter(child: DashboardHeader(totalBalance: totalBalance)),

        // ── Daily Breath Budget Bar ────────────────────────────────
        SliverToBoxAdapter(
          child: breathAsync.when(
            data: (state) => DailyBreathBar(budgetState: state),
            loading: () => const SizedBox(height: 80),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ),

        // ── Section title ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              'My Wallets',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),

        // ── Wallet Grid ────────────────────────────────────────────
        WalletGrid(
          wallets: wallets,
          onWalletTap: (wallet) => _onEditWallet(context, ref, wallet),
          onAddWallet: () => _onAddWallet(context, ref),
        ),

        // ── Recent Activity ────────────────────────────────────────
        const RecentActivitySection(),

        // ── Footer ────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Center(
              child: Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onAddWallet(BuildContext context, WidgetRef ref) async {
    final result = await WalletFormSheet.show(context);
    if (result == null) return;

    final repo = ref.read(walletRepositoryProvider);
    await repo.createWallet(result);
  }

  Future<void> _onEditWallet(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) async {
    final result = await WalletFormSheet.show(context, wallet: wallet);
    if (result == null) return;

    final repo = ref.read(walletRepositoryProvider);
    await repo.updateWallet(result);
  }
}
