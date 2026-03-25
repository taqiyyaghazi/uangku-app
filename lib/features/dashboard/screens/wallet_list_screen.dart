import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/features/dashboard/logic/wallet_search_logic.dart';
import 'package:uangku/features/dashboard/widgets/wallet_form_sheet.dart';
import 'package:uangku/features/dashboard/widgets/wallet_list_item.dart';

/// A full-screen wallet management hub with search and add functionality.
///
/// Displays all wallets in a vertical [ListView.separated] for easy scanning.
/// Includes a search bar for real-time client-side filtering by name.
/// A FAB provides quick access to the add-wallet form.
///
/// Consumes [walletsProvider] for reactive updates — the list auto-refreshes
/// when wallets are created, updated, or deleted (Drift stream).
class WalletListScreen extends ConsumerStatefulWidget {
  const WalletListScreen({super.key});

  @override
  ConsumerState<WalletListScreen> createState() => _WalletListScreenState();
}

class _WalletListScreenState extends ConsumerState<WalletListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletsAsync = ref.watch(walletsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallets'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              key: const Key('wallet_search_field'),
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search wallets...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        key: const Key('wallet_search_clear'),
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: walletsAsync.when(
        data: (wallets) => _buildList(context, wallets),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load wallets',
                style: theme.textTheme.titleMedium,
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
      floatingActionButton: FloatingActionButton(
        key: const Key('wallet_list_fab'),
        onPressed: () => _onAddWallet(context),
        tooltip: 'Add Wallet',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Wallet> wallets) {
    final theme = Theme.of(context);
    final filtered = filterWallets(wallets, _searchQuery);

    // --- Empty Search State ---
    if (filtered.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        key: const Key('wallet_search_empty_state'),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Dompetnya sembunyi di mana ya?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Coba cek ejaan namanya.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // --- Empty Wallet State ---
    if (wallets.isEmpty) {
      return Center(
        key: const Key('wallet_list_empty_state'),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No wallets yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to add your first wallet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // --- Wallet List ---
    return ListView.separated(
      key: const Key('wallet_list_view'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 88), // 88 for FAB space
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final wallet = filtered[index];
        return WalletListItem(
          wallet: wallet,
          isPrimary: index == 0 && _searchQuery.isEmpty,
          onTap: () => _onEditWallet(context, wallet),
        );
      },
    );
  }

  Future<void> _onAddWallet(BuildContext context) async {
    final result = await WalletFormSheet.show(context);
    if (result == null) return;

    final repo = ref.read(walletRepositoryProvider);
    await repo.createWallet(result);
  }

  Future<void> _onEditWallet(BuildContext context, Wallet wallet) async {
    final result = await WalletFormSheet.show(context, wallet: wallet);
    if (result == null) return;

    final repo = ref.read(walletRepositoryProvider);
    await repo.updateWallet(result);
  }
}
