import 'package:flutter/material.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/features/dashboard/widgets/wallet_card.dart';

/// A horizontal carousel of [WalletCard] widgets.
///
/// Used when there are multiple wallets to save vertical space.
/// Includes indicator dots if there are more than 3 wallets.
class WalletCarousel extends StatefulWidget {
  const WalletCarousel({super.key, required this.wallets, this.onWalletTap});

  final List<Wallet> wallets;
  final void Function(Wallet wallet)? onWalletTap;

  @override
  State<WalletCarousel> createState() => _WalletCarouselState();
}

class _WalletCarouselState extends State<WalletCarousel> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Approximate index based on scroll position and card width (approx 280)
    final index = (_scrollController.offset / 200).round();
    if (index != _currentIndex &&
        index >= 0 &&
        index < widget.wallets.length + 1) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalItems = widget.wallets.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 140,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: totalItems,
            itemBuilder: (context, index) {
              final wallet = widget.wallets[index];
              return Padding(
                padding: EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 280,
                  child: WalletCard(
                    wallet: wallet,
                    onTap: () => widget.onWalletTap?.call(wallet),
                  ),
                ),
              );
            },
          ),
        ),

        // --- Indicator Dots ---
        if (widget.wallets.length > 3) ...[
          const SizedBox(height: 12),
          Row(
            key: const Key('wallet_carousel_indicators'),
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalItems + 1, (index) {
              final isActive = _currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: isActive ? 16 : 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
