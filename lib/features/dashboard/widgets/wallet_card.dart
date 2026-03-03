import 'package:flutter/material.dart';

import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';
import 'package:uangku/shared/utils/wallet_icon_mapper.dart';

/// A single wallet card for the dashboard grid.
///
/// Displays the wallet's icon, name, type label, and formatted balance.
/// Uses the Ocean Flow teal accent for visual identity.
///
/// Calls [onTap] when the user taps the card (opens edit sheet).
class WalletCard extends StatelessWidget {
  const WalletCard({super.key, required this.wallet, this.onTap});

  final Wallet wallet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Parse user-selected color or fall back to teal.
    final walletColor = _parseColor(wallet.colorHex);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: walletColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: walletColor.withValues(alpha: isDark ? 0.1 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon + Type row ──────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: walletColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    WalletIconMapper.getIcon(wallet.icon),
                    color: walletColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    WalletIconMapper.getLabel(wallet.type),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: walletColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ── Wallet Name ──────────────────────────────────────────
            Text(
              wallet.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // ── Balance ──────────────────────────────────────────────
            Text(
              CurrencyFormatter.format(wallet.balance),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Parses a hex color string to [Color]. Falls back to teal on errors.
  static Color _parseColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.startsWith('#')) hex = hex.substring(1);
      if (hex.length == 6) buffer.write('FF');
      buffer.write(hex);
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return OceanFlowColors.primary;
    }
  }
}
