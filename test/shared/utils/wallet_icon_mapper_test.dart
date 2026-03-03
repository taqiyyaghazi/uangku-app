import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/data/tables/wallets_table.dart';
import 'package:uangku/shared/utils/wallet_icon_mapper.dart';

void main() {
  group('WalletIconMapper.getIcon', () {
    test('returns correct icon for known names', () {
      expect(WalletIconMapper.getIcon('cash'), Icons.payments_outlined);
      expect(WalletIconMapper.getIcon('bank'), Icons.account_balance_outlined);
    });

    test('returns fallback icon for unknown names', () {
      expect(
        WalletIconMapper.getIcon('unknown_icon'),
        Icons.account_balance_wallet_outlined,
      );
    });
  });

  group('WalletIconMapper.getIconForType', () {
    test('maps all WalletType values', () {
      for (final type in WalletType.values) {
        expect(WalletIconMapper.getIconForType(type), isA<IconData>());
      }
    });
  });

  group('WalletIconMapper.getLabel', () {
    test('returns human-readable labels', () {
      expect(WalletIconMapper.getLabel(WalletType.cash), 'Cash');
      expect(WalletIconMapper.getLabel(WalletType.bank), 'Bank');
      expect(WalletIconMapper.getLabel(WalletType.investment), 'Investment');
    });
  });

  group('WalletIconMapper.availableIcons', () {
    test('has at least 5 icons', () {
      expect(WalletIconMapper.availableIcons.length, greaterThanOrEqualTo(5));
    });

    test('is unmodifiable', () {
      expect(
        () => WalletIconMapper.availableIcons['x'] = Icons.abc,
        throwsUnsupportedError,
      );
    });
  });
}
