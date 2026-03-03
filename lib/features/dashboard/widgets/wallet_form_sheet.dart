import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:uangku/core/theme/app_theme.dart';
import 'package:uangku/data/database.dart';
import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/shared/utils/wallet_icon_mapper.dart';

/// Bottom sheet form for creating or editing a wallet.
///
/// When [wallet] is provided, the form is in "edit" mode.
/// When [wallet] is null, the form is in "create" mode.
///
/// Returns a [WalletsCompanion] through [Navigator.pop] on successful save.
class WalletFormSheet extends StatefulWidget {
  const WalletFormSheet({super.key, this.wallet});

  /// The wallet being edited, or null to create a new one.
  final Wallet? wallet;

  /// Shows a modal bottom sheet with the wallet form.
  ///
  /// Returns the [WalletsCompanion] on save, or null on dismiss.
  static Future<WalletsCompanion?> show(
    BuildContext context, {
    Wallet? wallet,
  }) {
    return showModalBottomSheet<WalletsCompanion>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => WalletFormSheet(wallet: wallet),
    );
  }

  @override
  State<WalletFormSheet> createState() => _WalletFormSheetState();
}

class _WalletFormSheetState extends State<WalletFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  late WalletType _selectedType;
  late String _selectedIcon;

  bool get _isEditing => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet?.name ?? '');
    _balanceController = TextEditingController(
      text: widget.wallet != null ? widget.wallet!.balance.toString() : '',
    );
    _selectedType = widget.wallet?.type ?? WalletType.cash;
    _selectedIcon = widget.wallet?.icon ?? 'wallet';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final balance = double.tryParse(_balanceController.text) ?? 0.0;

    final companion = WalletsCompanion(
      id: _isEditing ? Value(widget.wallet!.id) : const Value.absent(),
      name: Value(_nameController.text.trim()),
      balance: Value(balance),
      type: Value(_selectedType),
      icon: Value(_selectedIcon),
      updatedAt: Value(DateTime.now()),
    );

    Navigator.of(context).pop(companion);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Handle bar ───────────────────────────────────────
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Title ────────────────────────────────────────────
                Text(
                  _isEditing ? 'Edit Wallet' : 'New Wallet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Name Field ───────────────────────────────────────
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Wallet Name',
                    hintText: 'e.g. Bank BCA, Cash',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length > 100) {
                      return 'Name must be under 100 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Balance Field ────────────────────────────────────
                TextFormField(
                  controller: _balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Initial Balance',
                    hintText: '0',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      // ignore: deprecated_member_use
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final parsed = double.tryParse(value);
                      if (parsed == null) {
                        return 'Enter a valid number';
                      }
                      if (parsed < 0) {
                        return 'Balance cannot be negative';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Wallet Type Selector ─────────────────────────────
                Text(
                  'Type',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<WalletType>(
                  segments: WalletType.values.map((type) {
                    return ButtonSegment<WalletType>(
                      value: type,
                      label: Text(WalletIconMapper.getLabel(type)),
                      icon: Icon(WalletIconMapper.getIconForType(type)),
                    );
                  }).toList(),
                  selected: {_selectedType},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _selectedType = selection.first;
                      // Auto-update icon to match the type default.
                      _selectedIcon = _defaultIconForType(_selectedType);
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: OceanFlowColors.primary.withValues(
                      alpha: 0.15,
                    ),
                    selectedForegroundColor: OceanFlowColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Save Button ──────────────────────────────────────
                FilledButton.icon(
                  onPressed: _onSave,
                  icon: Icon(_isEditing ? Icons.save_outlined : Icons.add),
                  label: Text(_isEditing ? 'Save Changes' : 'Create Wallet'),
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
      ),
    );
  }

  String _defaultIconForType(WalletType type) {
    return switch (type) {
      WalletType.cash => 'cash',
      WalletType.bank => 'bank',
      WalletType.investment => 'investment',
    };
  }
}
