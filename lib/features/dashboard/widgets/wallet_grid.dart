import 'package:flutter/material.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/features/dashboard/widgets/wallet_card.dart';

/// A 2-column grid of [WalletCard] widgets.
///
/// Designed to be used as a sliver child inside a [CustomScrollView].
/// Calls [onWalletTap] when any card is tapped (for edit).
/// Calls [onAddWallet] when the "Add Wallet" card is tapped.
class WalletGrid extends StatelessWidget {
  const WalletGrid({
    super.key,
    required this.wallets,
    this.onWalletTap,
    this.onAddWallet,
  });

  final List<Wallet> wallets;
  final void Function(Wallet wallet)? onWalletTap;
  final VoidCallback? onAddWallet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Last item is the "Add Wallet" button card.
            if (index == wallets.length) {
              return _AddWalletCard(onTap: onAddWallet, theme: theme);
            }

            final wallet = wallets[index];
            return WalletCard(
              wallet: wallet,
              onTap: () => onWalletTap?.call(wallet),
            );
          },
          childCount: wallets.length + 1, // +1 for the add card
        ),
      ),
    );
  }
}

/// The "+" card at the end of the wallet grid.
class _AddWalletCard extends StatelessWidget {
  const _AddWalletCard({required this.onTap, required this.theme});

  final VoidCallback? onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              'Add Wallet',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
