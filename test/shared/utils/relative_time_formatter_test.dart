import 'package:flutter_test/flutter_test.dart';

import 'package:uangku/shared/utils/relative_time_formatter.dart';

void main() {
  // Fixed reference point for deterministic tests.
  final now = DateTime(2026, 3, 3, 15, 0);

  group('RelativeTimeFormatter', () {
    test('formats same-day date as "Today, HH:mm"', () {
      final date = DateTime(2026, 3, 3, 14, 30);
      expect(RelativeTimeFormatter.format(date, now: now), 'Today, 14:30');
    });

    test('formats yesterday as "Yesterday, HH:mm"', () {
      final date = DateTime(2026, 3, 2, 9, 15);
      expect(RelativeTimeFormatter.format(date, now: now), 'Yesterday, 09:15');
    });

    test('formats older date as "d MMM"', () {
      final date = DateTime(2026, 2, 28, 12, 0);
      expect(RelativeTimeFormatter.format(date, now: now), '28 Feb');
    });

    test('formats 2 days ago as date, not "Yesterday"', () {
      final date = DateTime(2026, 3, 1, 8, 0);
      expect(RelativeTimeFormatter.format(date, now: now), '1 Mar');
    });

    test('formats midnight today correctly', () {
      final date = DateTime(2026, 3, 3, 0, 0);
      expect(RelativeTimeFormatter.format(date, now: now), 'Today, 00:00');
    });

    test('formats late yesterday correctly', () {
      final date = DateTime(2026, 3, 2, 23, 59);
      expect(RelativeTimeFormatter.format(date, now: now), 'Yesterday, 23:59');
    });
  });
}
