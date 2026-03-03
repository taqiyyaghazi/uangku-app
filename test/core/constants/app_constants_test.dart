import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('appName should be Uangku', () {
      expect(AppConstants.appName, 'Uangku');
    });

    test('databaseName should end with .db', () {
      expect(AppConstants.databaseName, endsWith('.db'));
    });

    test('databaseVersion should be at least 1', () {
      expect(AppConstants.databaseVersion, greaterThanOrEqualTo(1));
    });
  });
}
