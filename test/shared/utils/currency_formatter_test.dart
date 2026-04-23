import 'package:flutter_test/flutter_test.dart';
import 'package:uangku/shared/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter (Masking)', () {
    test('format() returns masked string when isHidden is true', () {
      expect(CurrencyFormatter.format(150000, isHidden: true), equals('Rp ••••••'));
    });

    test('formatSigned() returns masked string when isHidden is true', () {
      expect(CurrencyFormatter.formatSigned(150000, isHidden: true), equals('Rp ••••••'));
      expect(CurrencyFormatter.formatSigned(-150000, isHidden: true), equals('Rp ••••••'));
    });

    test('formatCompact() returns masked string when isHidden is true', () {
      expect(CurrencyFormatter.formatCompact(1500000, isHidden: true), equals('Rp •••'));
      expect(CurrencyFormatter.formatCompact(500000, isHidden: true), equals('Rp •••'));
    });
    
    test('format() returns unmasked string when isHidden is false', () {
      // Basic check to ensure original functionality isn't broken
      final result = CurrencyFormatter.format(150000);
      expect(result.contains('150.000'), isTrue);
    });
  });
}
