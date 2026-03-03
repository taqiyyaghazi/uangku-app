import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/core/theme/app_theme.dart';

void main() {
  group('Ocean Flow Light Theme', () {
    late ThemeData theme;

    setUp(() {
      // No GoogleFonts injection — uses null textTheme (system default).
      theme = buildLightTheme();
    });

    test('should use Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('should have teal as primary color', () {
      expect(theme.colorScheme.primary, equals(OceanFlowColors.primary));
    });

    test('should use white background', () {
      expect(theme.scaffoldBackgroundColor, equals(OceanFlowColors.background));
    });

    test('should have rounded card shape', () {
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(cardShape.borderRadius, equals(BorderRadius.circular(16)));
    });

    test('FAB should use teal background', () {
      expect(
        theme.floatingActionButtonTheme.backgroundColor,
        equals(OceanFlowColors.primary),
      );
    });
  });

  group('Ocean Flow Dark Theme', () {
    late ThemeData theme;

    setUp(() {
      theme = buildDarkTheme();
    });

    test('should be dark brightness', () {
      expect(theme.brightness, equals(Brightness.dark));
    });

    test('should use dark background', () {
      expect(
        theme.scaffoldBackgroundColor,
        equals(OceanFlowColors.backgroundDark),
      );
    });

    test('should use lighter teal for dark primary', () {
      expect(theme.colorScheme.primary, equals(OceanFlowColors.primaryLight));
    });
  });

  group('OceanFlowColors', () {
    test('semantic colors should be distinct', () {
      final colors = {
        OceanFlowColors.income,
        OceanFlowColors.expense,
        OceanFlowColors.transfer,
      };
      expect(colors.length, 3, reason: 'Semantic colors must be unique');
    });

    test('primary and accent should be different', () {
      expect(OceanFlowColors.primary, isNot(equals(OceanFlowColors.accent)));
    });
  });
}
