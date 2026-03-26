import 'package:flutter/material.dart';

import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';
import 'package:uangku/shared/utils/wallet_icon_mapper.dart';

/// A horizontal list-item row for the wallet list screen.
///
/// Shows the wallet icon (colored), name, type label, and formatted balance.
/// Optionally shows a "Primary" badge when [isPrimary] is true.
///
/// Calls [onTap] when the user taps the row (to open the edit sheet).
class WalletListItem extends StatelessWidget {
  const WalletListItem({
    super.key,
    required this.wallet,
    this.isPrimary = false,
    this.onTap,
  });

  final Wallet wallet;
  final bool isPrimary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final walletColor = _parseColor(wallet.colorHex);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary
              ? walletColor.withValues(alpha: isDark ? 0.08 : 0.05)
              : null,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary
              ? Border.all(color: walletColor.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            // ── Icon ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: walletColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                WalletIconMapper.getIcon(wallet.icon),
                color: walletColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            // ── Name + Type ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          wallet.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: walletColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Primary',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: walletColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    WalletIconMapper.getLabel(wallet.type),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // ── Balance ───────────────────────────────────────────
            Text(
              CurrencyFormatter.format(wallet.balance),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(width: 4),

            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              size: 20,
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
