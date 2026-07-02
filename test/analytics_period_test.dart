import 'package:flutter_test/flutter_test.dart';

import 'package:faddompet/core/enums/analytics_period.dart';

void main() {
  test('currentMonth starts at the beginning of the month', () {
    final now = DateTime(2026, 7, 3, 14, 30);

    expect(AnalyticsPeriod.currentMonth.startDate(now), DateTime(2026, 7));
  });

  test('yearToDate starts at January 1', () {
    final now = DateTime(2026, 7, 3, 14, 30);

    expect(AnalyticsPeriod.yearToDate.startDate(now), DateTime(2026));
  });

  test('allTime has no start date', () {
    final now = DateTime(2026, 7, 3, 14, 30);

    expect(AnalyticsPeriod.allTime.startDate(now), isNull);
  });
}
