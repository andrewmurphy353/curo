import 'package:curo/src/daycount/day_count_origin.dart';
import 'package:curo/src/daycount/day_count_time_period.dart';
import 'package:curo/src/daycount/uk_conc_app_1_2.dart';
import 'package:test/test.dart';

void main() {
  group('UKConcApp12.computeFactor [timePeriod = undefined]', () {
    const dc = UKConcApp12();
    test('timePeriod() to return MONTH by default', () {
      expect(dc.timePeriod, DayCountTimePeriod.month);
    });
    test('dayCountOrigin() to return DRAWDOWN by default', () {
      expect(dc.dayCountOrigin(), DayCountOrigin.drawdown);
    });
    test('usePostDates() to return true', () {
      expect(dc.usePostDates, true);
    });
    test('includeNonFinancingFlows() to return true', () {
      expect(dc.includeNonFinancingFlows, true);
    });
  });
}
