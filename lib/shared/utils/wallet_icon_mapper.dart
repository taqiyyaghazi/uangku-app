import 'package:flutter/material.dart';

import 'package:uangku/data/tables/wallets_table.dart';

/// Maps wallet metadata to visual elements (icons, labels).
///
/// Pure utility — no I/O, fully testable.
class WalletIconMapper {
  WalletIconMapper._();

  /// Returns an [IconData] for the given wallet [iconName].
  ///
  /// Falls back to a generic wallet icon for unrecognized names.
  static IconData getIcon(String iconName) {
    return _iconMap[iconName] ?? Icons.account_balance_wallet_outlined;
  }

  /// Returns an appropriate default [IconData] for a [WalletType].
  static IconData getIconForType(WalletType type) {
    return switch (type) {
      WalletType.cash => Icons.payments_outlined,
      WalletType.bank => Icons.account_balance_outlined,
      WalletType.investment => Icons.trending_up_outlined,
    };
  }

  /// Returns a human-readable label for [WalletType].
  static String getLabel(WalletType type) {
    return switch (type) {
      WalletType.cash => 'Cash',
      WalletType.bank => 'Bank',
      WalletType.investment => 'Investment',
    };
  }

  /// Available icon name → IconData mapping.
  ///
  /// Users pick from this list when customizing a wallet.
  static const Map<String, IconData> _iconMap = {
    'wallet': Icons.account_balance_wallet_outlined,
    'cash': Icons.payments_outlined,
    'bank': Icons.account_balance_outlined,
    'investment': Icons.trending_up_outlined,
    'savings': Icons.savings_outlined,
    'credit_card': Icons.credit_card_outlined,
    'crypto': Icons.currency_bitcoin_outlined,
    'stock': Icons.candlestick_chart_outlined,
    'gold': Icons.diamond_outlined,
  };

  /// Returns all available icon entries for the wallet icon picker.
  static Map<String, IconData> get availableIcons => Map.unmodifiable(_iconMap);
}
