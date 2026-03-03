import 'package:flutter/material.dart';

import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/features/dashboard/models/budget_state.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';

/// An animated progress bar visualizing the Daily Breath budget.
///
/// Shows today's spending against the computed daily allowance.
/// - **Teal** when spending is within budget (ratio ≤ 1.0).
/// - **Amber** when overspent (ratio > 1.0) — "Gentle Adjustment" tone.
///
/// Uses [TweenAnimationBuilder] for smooth "breathing" transitions.
class DailyBreathBar extends StatelessWidget {
  const DailyBreathBar({super.key, required this.budgetState});

  final BudgetState budgetState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final barColor = budgetState.isOverspent
        ? OceanFlowColors.accent
        : OceanFlowColors.primary;

    final bgColor = isDark ? const Color(0xFF2C2C2C) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: barColor.withValues(alpha: isDark ? 0.1 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Breath',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${budgetState.remainingDays} days left',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: barColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Animated Progress Bar ────────────────────────────────
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: budgetState.progressRatio.clamp(0, 1)),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      backgroundColor: barColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation(barColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: ${CurrencyFormatter.format(budgetState.spentToday)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      Text(
                        'Limit: ${CurrencyFormatter.format(budgetState.dailyAllowance)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: barColor,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          // ── Correction Message (Amber Alert) ─────────────────────
          if (budgetState.isOverspent && budgetState.correctionMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: OceanFlowColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: OceanFlowColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: OceanFlowColors.accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        budgetState.correctionMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.white
                              : OceanFlowColors.onAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
