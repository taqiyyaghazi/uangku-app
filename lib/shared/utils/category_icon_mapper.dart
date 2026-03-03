import 'package:flutter/material.dart';

import 'package:uangku/core/theme/app_theme.dart';

/// Maps transaction category names to visual elements (icon + color).
///
/// Pure utility — no I/O, fully testable.
/// Follows the same pattern as [WalletIconMapper].
class CategoryIconMapper {
  CategoryIconMapper._();

  /// Returns the [IconData] and [Color] for a given [category] name.
  ///
  /// Falls back to a generic icon for unrecognized categories.
  static ({IconData icon, Color color}) get(String category) {
    return _categoryMap[category] ??
        (icon: Icons.receipt_outlined, color: OceanFlowColors.neutral);
  }

  static const Map<String, ({IconData icon, Color color})> _categoryMap = {
    // ── Expense categories ──────────────────────────────────────
    'Food': (icon: Icons.restaurant_outlined, color: Color(0xFFEF6C00)),
    'Transport': (
      icon: Icons.directions_car_outlined,
      color: Color(0xFF1565C0),
    ),
    'Shopping': (icon: Icons.shopping_bag_outlined, color: Color(0xFF7B1FA2)),
    'Bills': (icon: Icons.receipt_long_outlined, color: Color(0xFF455A64)),
    'Entertainment': (icon: Icons.movie_outlined, color: Color(0xFFD81B60)),
    'Health': (icon: Icons.local_hospital_outlined, color: Color(0xFFC62828)),
    'Education': (icon: Icons.school_outlined, color: Color(0xFF0277BD)),

    // ── Income categories ───────────────────────────────────────
    'Salary': (
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF2E7D32),
    ),
    'Freelance': (icon: Icons.laptop_mac_outlined, color: Color(0xFF00838F)),
    'Investment': (icon: Icons.trending_up_outlined, color: Color(0xFF1565C0)),
    'Gift': (icon: Icons.card_giftcard_outlined, color: Color(0xFFAD1457)),

    // ── Transfer ────────────────────────────────────────────────
    'Transfer': (icon: Icons.swap_horiz_outlined, color: Color(0xFF1565C0)),

    // ── Fallback ────────────────────────────────────────────────
    'Other': (icon: Icons.more_horiz_outlined, color: Color(0xFF757575)),
  };
}
