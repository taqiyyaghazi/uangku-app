import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/features/dashboard/logic/settings_providers.dart';

/// A bottom sheet that allows users to configure their total monthly budget.
class BudgetSettingModal extends ConsumerStatefulWidget {
  const BudgetSettingModal({super.key});

  /// Displays the modal bottom sheet and returns an optional configured [double] budget.
  static Future<void> show(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BudgetSettingModal(),
    );
  }

  @override
  ConsumerState<BudgetSettingModal> createState() => _BudgetSettingModalState();
}

class _BudgetSettingModalState extends ConsumerState<BudgetSettingModal> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    // Initialize with existing value if any.
    // If it hasn't loaded yet, it will just show empty.
    final asyncVal = ref.read(monthlyBudgetProvider);
    final val = asyncVal.value;
    if (val != null && val > 0) {
      _controller.text = val.toInt().toString(); // remove decimals for input
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final value = double.tryParse(_controller.text) ?? 0.0;

      final repo = ref.read(settingsRepositoryProvider);
      await repo.setDouble('monthly_budget', value);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // View insets handles the soft keyboard automatically pushing modal up
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Handle indicator ──────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header ───────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: OceanFlowColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.settings_suggest,
                      color: OceanFlowColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Monthly Budget',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Configure your baseline for Daily Breath calculations.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Input Field ──────────────────────────────────────────
              TextFormField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'Monthly Limit',
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter a budget amount';
                  }
                  final number = double.tryParse(val);
                  if (number == null) {
                    return 'Invalid number format';
                  }
                  if (number <= 0) {
                    return 'Budget must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // ── Save Button ──────────────────────────────────────────
              FilledButton(
                onPressed: _onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: OceanFlowColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Save Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
