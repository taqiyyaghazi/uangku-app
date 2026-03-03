import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/shared/utils/category_icon_mapper.dart';

void main() {
  group('CategoryIconMapper', () {
    test('returns correct icon and color for Food', () {
      final result = CategoryIconMapper.get('Food');
      expect(result.icon, Icons.restaurant_outlined);
      expect(result.color, const Color(0xFFEF6C00));
    });

    test('returns correct icon and color for Salary', () {
      final result = CategoryIconMapper.get('Salary');
      expect(result.icon, Icons.account_balance_wallet_outlined);
      expect(result.color, const Color(0xFF2E7D32));
    });

    test('returns correct icon and color for Transport', () {
      final result = CategoryIconMapper.get('Transport');
      expect(result.icon, Icons.directions_car_outlined);
    });

    test('returns correct icon and color for Shopping', () {
      final result = CategoryIconMapper.get('Shopping');
      expect(result.icon, Icons.shopping_bag_outlined);
    });

    test('returns correct icon and color for Transfer', () {
      final result = CategoryIconMapper.get('Transfer');
      expect(result.icon, Icons.swap_horiz_outlined);
    });

    test('returns fallback icon for unknown category', () {
      final result = CategoryIconMapper.get('NonExistentCategory');
      expect(result.icon, Icons.receipt_outlined);
    });

    test('returns fallback for empty string', () {
      final result = CategoryIconMapper.get('');
      expect(result.icon, Icons.receipt_outlined);
    });
  });
}
