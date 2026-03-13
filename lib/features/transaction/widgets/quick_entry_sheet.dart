import 'dart:developer' as developer;

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uangku/core/di/providers.dart';
import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/models/transaction_with_category.dart';
import 'package:uangku/data/tables/transactions_table.dart';
import 'package:uangku/features/transaction/widgets/numpad.dart';
import 'package:uangku/shared/utils/category_icon_mapper.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';
import 'package:uangku/shared/utils/wallet_icon_mapper.dart';
import 'package:uangku/shared/widgets/searchable_picker_sheet.dart';

/// Bottom sheet for quick transaction entry.
///
/// Provides a unified flow for Income, Expense, and Transfer with a
/// custom numpad for speed (< 3 seconds per entry).
class QuickEntrySheet extends ConsumerStatefulWidget {
  const QuickEntrySheet({super.key});

  /// Shows the entry sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const QuickEntrySheet(),
    );
  }

  @override
  ConsumerState<QuickEntrySheet> createState() => _QuickEntrySheetState();
}

class _QuickEntrySheetState extends ConsumerState<QuickEntrySheet> {
  TransactionType _type = TransactionType.expense;
  String _amountText = '0';
  int? _selectedWalletId;
  int? _selectedToWalletId;
  int? _selectedCategoryId;
  bool _isSaving = false;
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountText) ?? 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walletsAsync = ref.watch(walletsProvider);

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
              // ── Handle bar ───────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Transaction Type Toggle ──────────────────────────
              _buildTypeSelector(theme),
              const SizedBox(height: 16),

              // ── Amount Display ───────────────────────────────────
              _buildAmountDisplay(theme),
              const SizedBox(height: 16),

              // ── Wallet Selector ──────────────────────────────────
              walletsAsync.when(
                data: (wallets) {
                  if (_type == TransactionType.transfer) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'From Wallet',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildWalletSelector(theme, wallets, isSource: true),
                        const SizedBox(height: 12),
                        Text(
                          'To Wallet',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildWalletSelector(theme, wallets, isSource: false),
                        if (_selectedWalletId == _selectedToWalletId &&
                            _selectedWalletId != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Source and destination cannot be the same',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                  return _buildWalletSelector(theme, wallets, isSource: true);
                },
                loading: () => const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => const Text('Failed to load wallets'),
              ),
              const SizedBox(height: 12),

              // ── Category Selector ────────────────────────────────
              if (_type != TransactionType.transfer) ...[
                _buildCategorySelector(theme),
                const SizedBox(height: 12),
              ],

              // ── Note Field (Optional) ─────────────────────────────
              TextField(
                controller: _noteController,
                maxLength: 100,
                decoration: InputDecoration(
                  hintText: 'Add Note...',
                  counterText: '',
                  prefixIcon: const Icon(Icons.notes_outlined, size: 20),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
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

              // ── Custom Numpad ────────────────────────────────────
              Numpad(
                onDigit: _onDigit,
                onDecimal: _onDecimal,
                onBackspace: _onBackspace,
              ),
              const SizedBox(height: 12),

              // ── Save Button ──────────────────────────────────────
              FilledButton.icon(
                onPressed:
                    (_amount > 0 && _selectedWalletId != null && !_isSaving)
                    ? _onSave
                    : null,
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Transaction type segmented control ────────────────────────────

  Widget _buildTypeSelector(ThemeData theme) {
    return SegmentedButton<TransactionType>(
      segments: [
        ButtonSegment(
          value: TransactionType.expense,
          label: const Text('Expense'),
          icon: const Icon(Icons.arrow_upward, size: 18),
        ),
        ButtonSegment(
          value: TransactionType.income,
          label: const Text('Income'),
          icon: const Icon(Icons.arrow_downward, size: 18),
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
          _selectedCategoryId =
              null; // Reset selection so it auto-selects the first category of the new type
        });
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: _colorForType.withValues(alpha: 0.15),
        selectedForegroundColor: _colorForType,
      ),
    );
  }

  Color get _colorForType {
    return switch (_type) {
      TransactionType.income => OceanFlowColors.income,
      TransactionType.expense => OceanFlowColors.expense,
      TransactionType.transfer => OceanFlowColors.transfer,
    };
  }

  // ── Amount display ────────────────────────────────────────────────

  Widget _buildAmountDisplay(ThemeData theme) {
    // Determine if today is selected
    final now = DateTime.now();
    final isToday =
        _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    final dateText = isToday
        ? 'Today'
        : DateFormat('EEE, d MMM').format(_selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
          ActionChip(
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
                ? theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  )
                : OceanFlowColors.primary.withValues(alpha: 0.1),
            side: BorderSide.none,
            visualDensity: VisualDensity.compact,
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
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
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          now.hour,
          now.minute,
          now.second,
        );
      });
    }
  }

  // ── Wallet selector ───────────────────────────────────────────────

  Widget _buildWalletSelector(
    ThemeData theme,
    List<Wallet> wallets, {
    bool isSource = true,
  }) {
    if (wallets.isEmpty) {
      return Text(
        'No wallets available. Create one first.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }

    // Auto-select first wallet if none selected.
    if (isSource) {
      _selectedWalletId ??= wallets.first.id;
    } else {
      _selectedToWalletId ??= wallets.length > 1
          ? wallets[1].id
          : wallets.first.id;
    }

    final currentSelectedId = isSource
        ? _selectedWalletId
        : _selectedToWalletId;

    final selectedWallet = wallets.firstWhere(
      (w) => w.id == currentSelectedId,
      orElse: () => wallets.first,
    );

    return InkWell(
      onTap: () => _showWalletPicker(context, wallets, isSource),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              WalletIconMapper.getIcon(selectedWallet.icon),
              size: 20,
              color: OceanFlowColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedWallet.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              CurrencyFormatter.format(selectedWallet.balance),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showWalletPicker(
    BuildContext context,
    List<Wallet> wallets,
    bool isSource,
  ) async {
    final items = wallets.map((w) => PickerItem<int>(
      id: w.id,
      name: w.name,
      icon: WalletIconMapper.getIcon(w.icon),
      color: OceanFlowColors.primary,
      subtitle: CurrencyFormatter.format(w.balance),
    )).toList();

    final result = await SearchablePickerSheet.show<int>(
      context,
      title: isSource ? 'Select Source Wallet' : 'Select Destination Wallet',
      items: items,
      selectedId: isSource ? _selectedWalletId : _selectedToWalletId,
      searchPlaceholder: 'Search wallet name...',
    );

    if (result != null) {
      setState(() {
        if (isSource) {
          _selectedWalletId = result;
        } else {
          _selectedToWalletId = result;
        }
      });
    }
  }

  // ── Category selector ─────────────────────────────────────────────

  Widget _buildCategorySelector(ThemeData theme) {
    final categoriesAsync = ref.watch(categoriesByTypeProvider(_type));
    final recentTxAsync = ref.watch(recentTransactionsProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Text(
            'No categories available. Please create one.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          );
        }

        // Auto-select first category if none selected or if selected is not in the list.
        if (_selectedCategoryId == null ||
            !categories.any((c) => c.id == _selectedCategoryId)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _selectedCategoryId = categories.first.id);
            }
          });
        }

        final selectedCategory = categories.firstWhere(
          (c) => c.id == _selectedCategoryId,
          orElse: () => categories.first,
        );

        final categoryInfo = CategoryIconMapper.get(selectedCategory.name);

        return InkWell(
          onTap: () => _showCategoryPicker(context, categories, recentTxAsync.value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  categoryInfo.icon,
                  size: 20,
                  color: categoryInfo.color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedCategory.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const Text('Failed to load categories'),
    );
  }

  Future<void> _showCategoryPicker(
    BuildContext context,
    List<Category> categories,
    List<TransactionWithCategory>? recentTransactions,
  ) async {
    final items = categories.map((c) {
      final info = CategoryIconMapper.get(c.name);
      return PickerItem<int>(
        id: c.id,
        name: c.name,
        icon: info.icon,
        color: info.color,
      );
    }).toList();

    // Determine recent categories (up to 3 unique from recent transactions of the same type)
    List<PickerItem<int>>? recentItems;
    if (recentTransactions != null) {
      final recentIds = recentTransactions
          .where((tx) => tx.transaction.type == _type && tx.category != null)
          .map((tx) => tx.category!.id)
          .toSet()
          .take(3);
      
      recentItems = items.where((item) => recentIds.contains(item.id)).toList();
    }

    final result = await SearchablePickerSheet.show<int>(
      context,
      title: 'Select Category',
      items: items,
      recentItems: recentItems,
      selectedId: _selectedCategoryId,
      addNewLabel: 'Add New Category',
      onAddNew: (query) => _onAddNewCategory(query),
      searchPlaceholder: 'Search category name...',
    );

    if (result != null) {
      setState(() => _selectedCategoryId = result);
    }
  }

  void _onAddNewCategory(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add Category "$name" coming soon!')),
    );
  }

  // ── Numpad callbacks ──────────────────────────────────────────────

  void _onDigit(String digit) {
    setState(() {
      if (_amountText == '0' && digit != '0') {
        _amountText = digit;
      } else if (_amountText != '0') {
        // Limit decimal places to 2.
        if (_amountText.contains('.')) {
          final parts = _amountText.split('.');
          if (parts[1].length >= 2) return;
        }
        // Limit total digits to prevent overflow.
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

  // ── Save transaction ──────────────────────────────────────────────

  Future<void> _onSave() async {
    if (_selectedWalletId == null || _amount <= 0) return;
    if (_type != TransactionType.transfer && _selectedCategoryId == null) {
      return;
    }
    if (_type == TransactionType.transfer &&
        (_selectedToWalletId == null ||
            _selectedWalletId == _selectedToWalletId)) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(transactionRepositoryProvider);

      if (_type == TransactionType.transfer) {
        await repo.performInternalTransfer(
          fromWalletId: _selectedWalletId!,
          toWalletId: _selectedToWalletId!,
          amount: _amount,
          date: _selectedDate,
          note: _noteController.text,
        );

        if (mounted) {
          final wallets = ref.read(walletsProvider).value ?? [];
          final toWallet = wallets.firstWhere(
            (w) => w.id == _selectedToWalletId,
            orElse: () => wallets.first,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Rp ${_amount.toStringAsFixed(0)} moved to ${toWallet.name}',
              ),
              backgroundColor: OceanFlowColors.primary,
            ),
          );
        }
      } else {
        // Determine balance delta based on type.
        final balanceDelta = switch (_type) {
          TransactionType.income => _amount,
          TransactionType.expense => -_amount,
          TransactionType.transfer => 0.0, // Should not reach here
        };

        final companion = TransactionsCompanion(
          walletId: Value(_selectedWalletId!),
          amount: Value(_amount),
          type: Value(_type),
          categoryId: Value(_selectedCategoryId!),
          note: Value(_noteController.text),
          date: Value(_selectedDate),
        );

        await repo.insertTransactionAndUpdateBalance(
          transaction: companion,
          walletId: _selectedWalletId!,
          balanceDelta: balanceDelta,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      developer.log(
        'Error saving quick transaction',
        name: 'QuickEntrySheet',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: OceanFlowColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
