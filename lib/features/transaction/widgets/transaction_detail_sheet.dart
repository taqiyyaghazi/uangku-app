import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/services/monitoring_service.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/transaction/logic/transaction_balance_logic.dart';
import 'package:uangku/features/transaction/widgets/numpad.dart';
import 'package:uangku/shared/utils/category_icon_mapper.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';
import 'package:uangku/shared/utils/relative_time_formatter.dart';
import 'dart:developer' as developer;

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

  final TransactionWithCategory transaction;
  final String walletName;

  /// Shows the detail sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required TransactionWithCategory transaction,
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
  late int _selectedCategoryId;
  late DateTime _selectedDate;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _resetEditState();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _resetEditState() {
    final tx = widget.transaction.transaction;
    _type = tx.type;
    _amountText = tx.amount.truncateToDouble() == tx.amount
        ? tx.amount.toInt().toString()
        : tx.amount.toString();
    _selectedCategoryId = tx.categoryId ?? 0;
    _noteController.text = tx.note;
    _selectedDate = tx.date;
  }

  double get _amount => double.tryParse(_amountText) ?? 0.0;

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
    final tx = widget.transaction.transaction;
    final cat = widget.transaction.category;

    final String iconCode = cat?.iconCode ?? 'swap_horiz';
    final String catName = cat?.name ?? 'Transfer';

    final categoryInfo = CategoryIconMapper.get(
      iconCode.isNotEmpty ? iconCode : catName,
    );
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
                  catName,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyFormatter.format(_amount),
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: _colorForType,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            _buildDateSelector(theme),
          ],
        ),
      ),
      const SizedBox(height: 12),

      // ── Category Selector ──────────────────────────────────────
      Consumer(
        builder: (context, ref, _) {
          final categoriesAsync = ref
              .watch(categoryRepositoryProvider)
              .watchCategoriesByType(_type);
          return SizedBox(
            height: 36,
            child: StreamBuilder(
              stream: categoriesAsync,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final categories = snapshot.data!;

                if (!categories.any((c) => c.id == _selectedCategoryId)) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _selectedCategoryId = categories.first.id);
                    }
                  });
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category.id == _selectedCategoryId;
                    return ChoiceChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedCategoryId = category.id),
                      selectedColor: _colorForType.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? _colorForType
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      const SizedBox(height: 12),

      // ── Note Field ───────────────────────────────────────────────
      TextField(
        controller: _noteController,
        maxLength: 100,
        decoration: InputDecoration(
          hintText: 'Add Note...',
          counterText: '',
          prefixIcon: const Icon(Icons.notes_outlined, size: 20),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        style: theme.textTheme.bodyMedium,
        textInputAction: TextInputAction.done,
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

  // ── Edit mode helpers ──────────────────────────────────────────────

  Widget _buildDateSelector(ThemeData theme) {
    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    final dateText = isToday
        ? 'Today'
        : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';

    return ActionChip(
      avatar: Icon(
        Icons.calendar_today,
        size: 16,
        color: isToday
            ? theme.colorScheme.onSurfaceVariant
            : OceanFlowColors.primary,
      ),
      label: Text(dateText),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isToday ? FontWeight.w500 : FontWeight.w600,
        color: isToday
            ? theme.colorScheme.onSurfaceVariant
            : OceanFlowColors.primary,
      ),
      backgroundColor: isToday
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : OceanFlowColors.primary.withValues(alpha: 0.1),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
      onPressed: () => _selectDate(context),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: OceanFlowColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Keep the current time for chronological sorting
        final originalDate = widget.transaction.transaction.date;
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          originalDate.hour,
          originalDate.minute,
          originalDate.second,
        );
      });
    }
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
      await repo.deleteTransactionAtomic(widget.transaction.transaction);

      await ref
          .read(monitoringServiceProvider)
          .logEvent(
            name: 'transaction_deleted',
            parameters: {
              'type': widget.transaction.transaction.type.name,
              'category': widget.transaction.category?.name ?? 'Transfer',
            },
          );

      if (mounted) Navigator.of(context).pop();
    } catch (e, st) {
      developer.log(
        'Error deleting transaction',
        name: 'TransactionDetailSheet',
        error: e,
        stackTrace: st,
      );

      await ref
          .read(monitoringServiceProvider)
          .recordError(e, st, reason: 'Failed to delete transaction');

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
      final monitoring = ref.read(monitoringServiceProvider);

      final balanceDelta = TransactionBalanceLogic.updateDelta(
        old: widget.transaction.transaction,
        newAmount: _amount,
        newType: _type,
      );

      final companion = TransactionsCompanion(
        amount: Value(_amount),
        type: Value(_type),
        categoryId: Value(_selectedCategoryId),
        note: Value(_noteController.text),
        date: Value(_selectedDate),
      );

      await repo.updateTransactionAtomic(
        transactionId: widget.transaction.transaction.id,
        updated: companion,
        walletId: widget.transaction.transaction.walletId,
        balanceDelta: balanceDelta,
      );

      // Log analytics.
      final dateChanged = _selectedDate != widget.transaction.transaction.date;
      await monitoring.logEvent(
        name: 'transaction_updated',
        parameters: {
          'type': _type.name,
          'date_changed': dateChanged,
          'amount_changed': _amount != widget.transaction.transaction.amount,
          'note_length': _noteController.text.length,
        },
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction updated'),
            backgroundColor: OceanFlowColors.primary,
          ),
        );
      }
    } catch (e, st) {
      developer.log(
        'Error saving transaction edit',
        name: 'TransactionDetailSheet',
        error: e,
        stackTrace: st,
      );

      await ref
          .read(monitoringServiceProvider)
          .recordError(e, st, reason: 'Failed to save transaction edit');

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
