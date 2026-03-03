import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:uangku/core/theme/app_theme.dart';

/// A custom numerical keypad for fast transaction amount entry.
///
/// Avoids the latency of the system keyboard sliding up.
/// Provides haptic feedback on each tap for a tactile "speed" feel.
///
/// Calls [onDigit] when a digit (0–9) is tapped.
/// Calls [onDecimal] when the decimal point is tapped.
/// Calls [onBackspace] when backspace is tapped.
class Numpad extends StatelessWidget {
  const Numpad({
    super.key,
    required this.onDigit,
    required this.onDecimal,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDecimal;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: [
        _NumpadButton(label: '1', onTap: () => _tapDigit('1'), theme: theme),
        _NumpadButton(label: '2', onTap: () => _tapDigit('2'), theme: theme),
        _NumpadButton(label: '3', onTap: () => _tapDigit('3'), theme: theme),
        _NumpadButton(label: '4', onTap: () => _tapDigit('4'), theme: theme),
        _NumpadButton(label: '5', onTap: () => _tapDigit('5'), theme: theme),
        _NumpadButton(label: '6', onTap: () => _tapDigit('6'), theme: theme),
        _NumpadButton(label: '7', onTap: () => _tapDigit('7'), theme: theme),
        _NumpadButton(label: '8', onTap: () => _tapDigit('8'), theme: theme),
        _NumpadButton(label: '9', onTap: () => _tapDigit('9'), theme: theme),
        _NumpadButton(label: '.', onTap: _tapDecimal, theme: theme),
        _NumpadButton(label: '0', onTap: () => _tapDigit('0'), theme: theme),
        _NumpadButton(
          icon: Icons.backspace_outlined,
          onTap: _tapBackspace,
          theme: theme,
        ),
      ],
    );
  }

  void _tapDigit(String digit) {
    HapticFeedback.lightImpact();
    onDigit(digit);
  }

  void _tapDecimal() {
    HapticFeedback.lightImpact();
    onDecimal();
  }

  void _tapBackspace() {
    HapticFeedback.lightImpact();
    onBackspace();
  }
}

/// Individual numpad button with ink effect and haptic-ready styling.
class _NumpadButton extends StatelessWidget {
  const _NumpadButton({
    this.label,
    this.icon,
    required this.onTap,
    required this.theme,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: OceanFlowColors.primary.withValues(alpha: 0.1),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 24, color: theme.colorScheme.onSurface)
              : Text(
                  label!,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
