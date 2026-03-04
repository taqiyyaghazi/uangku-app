import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/shared/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter.format', () {
    test('formats whole numbers without decimals', () {
      expect(CurrencyFormatter.format(1250000), 'Rp 1.250.000');
    });

    test('formats zero', () {
      expect(CurrencyFormatter.format(0), 'Rp 0');
    });

    test('formats fractional amounts with 2 decimals', () {
      expect(CurrencyFormatter.format(1500.50), 'Rp 1.500,50');
    });

    test('formats small amounts', () {
      expect(CurrencyFormatter.format(500), 'Rp 500');
    });

    test('formats large amounts with thousand separators', () {
      expect(CurrencyFormatter.format(999999999), 'Rp 999.999.999');
    });
  });

  group('CurrencyFormatter.formatSigned', () {
    test('positive amounts get + prefix', () {
      expect(CurrencyFormatter.formatSigned(50000), '+Rp 50.000');
    });

    test('negative amounts get - prefix', () {
      expect(CurrencyFormatter.formatSigned(-25000), '-Rp 25.000');
    });

    test('zero has no sign prefix', () {
      expect(CurrencyFormatter.formatSigned(0), 'Rp 0');
    });
  });
  group('CurrencyFormatter.formatCompact', () {
    test('formats millions to M', () {
      expect(CurrencyFormatter.formatCompact(1200000), 'Rp 1,2M');
      expect(CurrencyFormatter.formatCompact(1000000), 'Rp 1M');
    });

    test('formats thousands to k', () {
      expect(CurrencyFormatter.formatCompact(150000), 'Rp 150k');
      expect(CurrencyFormatter.formatCompact(1000), 'Rp 1k');
    });

    test('formats small amounts normally', () {
      expect(CurrencyFormatter.formatCompact(500), 'Rp 500');
    });

    test('handles decimals when necessary', () {
      expect(
        CurrencyFormatter.formatCompact(1250000),
        'Rp 1,3M',
      ); // toStringAsFixed(1)
      expect(
        CurrencyFormatter.formatCompact(1000.5),
        'Rp 1k',
      ); // 1000.5 / 1000 = 1.0005 -> 1.0
    });
  });
}
