import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/core/constants/transaction_categories.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/transaction/logic/transaction_balance_logic.dart';
import 'package:uangku/features/transaction/widgets/numpad.dart';
import 'package:uangku/shared/utils/category_icon_mapper.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';
import 'package:uangku/shared/utils/relative_time_formatter.dart';

/// Bottom sheet for viewing, editing, and deleting a transaction.
///
/// Opens in **view mode** by default. Users can switch to edit mode
/// to modify the transaction or delete it with a confirmation dialog.
class TransactionDetailSheet extends ConsumerStatefulWidget {
  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    required this.walletName,
  });

  final Transaction transaction;
  final String walletName;

  /// Shows the detail sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required Transaction transaction,
    required String walletName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TransactionDetailSheet(
        transaction: transaction,
        walletName: walletName,
      ),
    );
  }

  @override
  ConsumerState<TransactionDetailSheet> createState() =>
      _TransactionDetailSheetState();
}

class _TransactionDetailSheetState
    extends ConsumerState<TransactionDetailSheet> {
  bool _isEditing = false;
  bool _isSaving = false;

  // Edit mode state.
  late TransactionType _type;
  late String _amountText;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _resetEditState();
  }

  void _resetEditState() {
    _type = widget.transaction.type;
    _amountText =
        widget.transaction.amount.truncateToDouble() ==
            widget.transaction.amount
        ? widget.transaction.amount.toInt().toString()
        : widget.transaction.amount.toString();
    _selectedCategory = widget.transaction.category;
  }

  double get _amount => double.tryParse(_amountText) ?? 0.0;

  List<String> get _categoriesForType {
    return switch (_type) {
      TransactionType.income => TransactionCategories.income,
      TransactionType.expense => TransactionCategories.expense,
      TransactionType.transfer => TransactionCategories.transfer,
    };
  }

  Color get _colorForType {
    return switch (_type) {
      TransactionType.income => OceanFlowColors.income,
      TransactionType.expense => OceanFlowColors.expense,
      TransactionType.transfer => OceanFlowColors.transfer,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Handle bar ─────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              if (_isEditing) ..._buildEditMode() else ..._buildViewMode(),
            ],
          ),
        ),
      ),
    );
  }

  // ── View Mode ──────────────────────────────────────────────────────

  List<Widget> _buildViewMode() {
    final theme = Theme.of(context);
    final tx = widget.transaction;
    final categoryInfo = CategoryIconMapper.get(tx.category);
    final isIncome = tx.type == TransactionType.income;
    final amountColor = isIncome
        ? OceanFlowColors.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final amountPrefix = isIncome ? '+' : '-';

    return [
      // ── Category Icon + Name ───────────────────────────────────
      Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: categoryInfo.color.withValues(alpha: 0.12),
            child: Icon(categoryInfo.icon, color: categoryInfo.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.category,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${_typeLabel(tx.type)} · ${widget.walletName}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),

      // ── Amount ─────────────────────────────────────────────────
      Center(
        child: Text(
          '$amountPrefix${CurrencyFormatter.format(tx.amount)}',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: amountColor,
          ),
        ),
      ),
      const SizedBox(height: 16),

      // ── Details ────────────────────────────────────────────────
      _buildDetailRow(
        theme,
        icon: Icons.calendar_today_outlined,
        label: RelativeTimeFormatter.format(tx.date),
      ),
      if (tx.note.isNotEmpty)
        _buildDetailRow(theme, icon: Icons.notes_outlined, label: tx.note),
      const SizedBox(height: 24),

      // ── Action Buttons ─────────────────────────────────────────
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _resetEditState();
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _onDelete,
              icon: const Icon(Icons.delete_outlined),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: OceanFlowColors.error,
                side: const BorderSide(color: OceanFlowColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildDetailRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit Mode ──────────────────────────────────────────────────────

  List<Widget> _buildEditMode() {
    final theme = Theme.of(context);

    return [
      // ── Type Selector ──────────────────────────────────────────
      SegmentedButton<TransactionType>(
        segments: [
          ButtonSegment(
            value: TransactionType.expense,
            label: const Text('Expense'),
            icon: const Icon(Icons.arrow_downward, size: 18),
          ),
          ButtonSegment(
            value: TransactionType.income,
            label: const Text('Income'),
            icon: const Icon(Icons.arrow_upward, size: 18),
          ),
          ButtonSegment(
            value: TransactionType.transfer,
            label: const Text('Transfer'),
            icon: const Icon(Icons.swap_horiz, size: 18),
          ),
        ],
        selected: {_type},
        onSelectionChanged: (selection) {
          setState(() {
            _type = selection.first;
            if (!_categoriesForType.contains(_selectedCategory)) {
              _selectedCategory = _categoriesForType.first;
            }
          });
        },
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: _colorForType.withValues(alpha: 0.15),
          selectedForegroundColor: _colorForType,
        ),
      ),
      const SizedBox(height: 16),

      // ── Amount Display ─────────────────────────────────────────
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            CurrencyFormatter.format(_amount),
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: _colorForType,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      const SizedBox(height: 12),

      // ── Category Selector ──────────────────────────────────────
      SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categoriesForType.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final category = _categoriesForType[index];
            final isSelected = category == _selectedCategory;
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              selectedColor: _colorForType.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? _colorForType : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              visualDensity: VisualDensity.compact,
            );
          },
        ),
      ),
      const SizedBox(height: 16),

      // ── Numpad ─────────────────────────────────────────────────
      Numpad(
        onDigit: _onDigit,
        onDecimal: _onDecimal,
        onBackspace: _onBackspace,
      ),
      const SizedBox(height: 12),

      // ── Save / Cancel ──────────────────────────────────────────
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                debugPrint('CANCEL TAPPED');
                setState(() => _isEditing = false);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: (_amount > 0 && !_isSaving) ? _onSaveEdit : null,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSaving ? 'Saving...' : 'Save'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  // ── Numpad callbacks ───────────────────────────────────────────────

  void _onDigit(String digit) {
    setState(() {
      if (_amountText == '0' && digit != '0') {
        _amountText = digit;
      } else if (_amountText != '0') {
        if (_amountText.contains('.')) {
          final parts = _amountText.split('.');
          if (parts[1].length >= 2) return;
        }
        if (_amountText.replaceAll('.', '').length >= 12) return;
        _amountText += digit;
      }
    });
  }

  void _onDecimal() {
    setState(() {
      if (!_amountText.contains('.')) {
        _amountText += '.';
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amountText.length <= 1) {
        _amountText = '0';
      } else {
        _amountText = _amountText.substring(0, _amountText.length - 1);
      }
    });
  }

  // ── Actions ────────────────────────────────────────────────────────

  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction? '
          'The wallet balance will be adjusted accordingly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: OceanFlowColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.deleteTransactionAtomic(widget.transaction);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: OceanFlowColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _onSaveEdit() async {
    if (_amount <= 0) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(transactionRepositoryProvider);

      final balanceDelta = TransactionBalanceLogic.updateDelta(
        old: widget.transaction,
        newAmount: _amount,
        newType: _type,
      );

      final companion = TransactionsCompanion(
        amount: Value(_amount),
        type: Value(_type),
        category: Value(_selectedCategory),
      );

      await repo.updateTransactionAtomic(
        transactionId: widget.transaction.id,
        updated: companion,
        walletId: widget.transaction.walletId,
        balanceDelta: balanceDelta,
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: OceanFlowColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _typeLabel(TransactionType type) {
    return switch (type) {
      TransactionType.income => 'Income',
      TransactionType.expense => 'Expense',
      TransactionType.transfer => 'Transfer',
    };
  }
}
