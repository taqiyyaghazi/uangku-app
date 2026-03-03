import 'package:flutter/material.dart';

import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';

/// Dashboard header displaying the user's total balance across all wallets.
///
/// Shows a prominent total with a subtle label above it.
/// Uses the Ocean Flow teal gradient for visual emphasis.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.totalBalance});

  final double totalBalance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A3A3A), const Color(0xFF121212)]
              : [OceanFlowColors.primary, OceanFlowColors.primaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(totalBalance),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
