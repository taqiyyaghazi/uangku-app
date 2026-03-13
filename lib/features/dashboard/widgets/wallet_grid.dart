import 'package:flutter/material.dart';

import 'package:uangku/data/database.dart';
import 'package:uangku/features/dashboard/widgets/add_wallet_card.dart';
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
              return AddWalletCard(onTap: onAddWallet);
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
