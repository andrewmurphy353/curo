import 'package:curo/src/daycount/day_count_origin.dart';
import 'package:curo/src/daycount/day_count_time_period.dart';
import 'package:curo/src/daycount/uk_conc_app_1_1.dart';
import 'package:test/test.dart';

void main() {
  group(
      'UKConcApp11.computeFactor '
      '[hasSingleRepayment = false, timePeriod = month]', () {
    const dc = UKConcApp11(timePeriod: DayCountTimePeriod.month);
    test('timePeriod() to return month', () {
      expect(dc.timePeriod, DayCountTimePeriod.month);
    });
    test('31/01/2025 --> 28/02/2025 (whole weeks and months, use months)', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2025, 2, 28),
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(1/12) = 0.08333333');
      expect(dcf.toFoldedString(), '(1/12) = 0.08333333');
    });
    test('31/01/2025 --> 28/02/2029 (whole weeks and months, use months)', () {
      // Period devisible by whole weeks and months
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2031, 2, 28),
      );
      expect(dcf.factor, 6.08333333333333333);
      expect(dcf.toString(), '6 + (1/12) = 6.08333333');
      expect(dcf.toFoldedString(), '6 + (1/12) = 6.08333333');
    });
    test('12/01/2025 --> 15/02/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 12),
        DateTime.utc(2025, 2, 15),
      );
      expect(dcf.factor, 0.0915525114155251);
      expect(dcf.toString(), '(1/12) + (3/365) = 0.09155251');
      expect(dcf.toFoldedString(), '(1/12) + (3/365) = 0.09155251');
    });
    test('15/01/2025 --> 12/02/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 15),
        DateTime.utc(2025, 2, 12),
      );
      expect(dcf.factor, 0.07671232876712329);
      expect(dcf.toString(), '(28/365) = 0.07671233');
      expect(dcf.toFoldedString(), '(28/365) = 0.07671233');
    });
    test('12/12/2024 --> 15/02/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 12, 12),
        DateTime.utc(2025, 2, 15),
      );
      expect(dcf.factor, 0.17488584474885843);
      expect(dcf.toString(), '(2/12) + (3/365) = 0.17488584');
      expect(dcf.toFoldedString(), '(2/12) + (3/365) = 0.17488584');
    });
    test('15/12/2023 --> 29/02/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2023, 12, 15),
        DateTime.utc(2024, 2, 29),
      );
      expect(dcf.factor, 0.20491803278688525);
      expect(dcf.toString(), '(2/12) + (14/366) = 0.20491803');
      expect(dcf.toFoldedString(), '(2/12) + (14/366) = 0.20491803');
    });
    test('12/12/2024 --> 01/01/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 12, 12),
        DateTime.utc(2025, 1, 1),
      );
      expect(dcf.factor, 0.054652294333408194);
      expect(dcf.toString(), '(19/366) + (1/365) = 0.05465229');
      expect(dcf.toFoldedString(), '(19/366) + (1/365) = 0.05465229');
    });
    test('29/11/2023 --> 29/02/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2023, 11, 29),
        DateTime.utc(2024, 2, 29),
      );
      expect(dcf.factor, 0.250000000000000);
      expect(dcf.toString(), '(3/12) = 0.25000000');
      expect(dcf.toFoldedString(), '(3/12) = 0.25000000');
    });
    test('30/11/2023 --> 29/02/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2023, 11, 30),
        DateTime.utc(2024, 2, 29),
      );
      expect(dcf.factor, 0.250000000000000);
      expect(dcf.toString(), '(3/12) = 0.25000000');
      expect(dcf.toFoldedString(), '(3/12) = 0.25000000');
    });
    test('25/02/2024 --> 28/03/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 2, 25),
        DateTime.utc(2024, 3, 28),
      );
      expect(dcf.factor, 0.09153005464480873);
      expect(dcf.toString(), '(1/12) + (3/366) = 0.09153005');
      expect(dcf.toFoldedString(), '(1/12) + (3/366) = 0.09153005');
    });
    test('26/02/2025 --> 26/02/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 2, 26),
        DateTime.utc(2025, 2, 26),
      );
      expect(dcf.factor, 0.0);
      expect(dcf.toString(), '0 = 0.00000000');
      expect(dcf.toFoldedString(), '0 = 0.00000000');
    });
    test('31/12/2024 --> 28/02/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 12, 31),
        DateTime.utc(2025, 2, 28),
      );
      expect(dcf.factor, 0.16666666666666666);
      expect(dcf.toString(), '(2/12) = 0.16666667');
      expect(dcf.toFoldedString(), '(2/12) = 0.16666667');
    });
    test('28/02/2024 --> 31/03/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 2, 28),
        DateTime.utc(2024, 3, 31),
      );
      expect(dcf.factor, 0.09153005464480873);
      expect(dcf.toString(), '(1/12) + (3/366) = 0.09153005');
      expect(dcf.toFoldedString(), '(1/12) + (3/366) = 0.09153005');
    });
    test('29/02/2024 --> 31/03/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 2, 29),
        DateTime.utc(2024, 3, 31),
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(1/12) = 0.08333333');
      expect(dcf.toFoldedString(), '(1/12) = 0.08333333');
    });
    test('31/01/2024 <-- 29/02/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 1, 31),
        DateTime.utc(2024, 2, 29),
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(1/12) = 0.08333333');
      expect(dcf.toFoldedString(), '(1/12) = 0.08333333');
    });
    test('31/01/2024 <-- 28/02/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 1, 31),
        DateTime.utc(2025, 2, 28),
      );
      expect(dcf.factor, 1.08333333333333333);
      expect(dcf.toString(), '1 + (1/12) = 1.08333333');
      expect(dcf.toFoldedString(), '1 + (1/12) = 1.08333333');
    });
  });
  group(
      'UKConcApp11.computeFactor '
      '[hasSingleRepayment = true, timePeriod = month]', () {
    const dc = UKConcApp11(
      hasSingleRepayment: true,
      timePeriod: DayCountTimePeriod.month,
    );
    test('timePeriod() to return month', () {
      expect(dc.timePeriod, DayCountTimePeriod.month);
    });
    test('31/01/2025 --> 28/02/2025 (whole weeks and months, use months)', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2025, 2, 28),
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(1/12) = 0.08333333');
      expect(dcf.toFoldedString(), '(1/12) = 0.08333333');
    });
    test('31/01/2025 --> 28/02/2029 (whole weeks and months, use months)', () {
      // Period devisible by whole weeks and months
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2031, 2, 28),
      );
      expect(dcf.factor, 6.08333333333333333);
      expect(dcf.toString(), '6 + (1/12) = 6.08333333');
      expect(dcf.toFoldedString(), '6 + (1/12) = 6.08333333');
    });
  });
  group(
      'UKConcApp11.computeFactor '
      '[hasSingleRepayment = false, timePeriod = week]', () {
    const dc = UKConcApp11(
      timePeriod: DayCountTimePeriod.week,
    );
    test('timePeriod() to return week', () {
      expect(dc.timePeriod, DayCountTimePeriod.week);
    });
    test('31/01/2025 --> 28/02/2025 (whole weeks and months, use weeks)', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2025, 2, 28),
      );
      expect(dcf.factor, 0.07692307692307693);
      expect(dcf.toString(), '(4/52) = 0.07692308');
      expect(dcf.toFoldedString(), '(4/52) = 0.07692308');
    });
    test('31/01/2025 --> 28/02/2031 (whole weeks and months, use weeks)', () {
      // The Curo implementation uses *actual* weeks between dates as CONC does
      // not specify the use of calendar weeks, only calendar months. The
      // difference may lead to variances when two dates span several years as
      // highlighted in this test. The actual weeks = 317, which is 1 week more
      // than the period in calendar weeks (6 years * 52 + 4 = 316).The emphasis
      // of CONC on consumer protection and the need for precise time
      // measurement in credit agreements would suggest that using actual days
      // (and thus deriving weeks from these) is the more compliant approach.
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2031, 2, 28),
      );
      expect(dcf.factor, 6.096153846153846);
      expect(dcf.toString(), '6 + (5/52) = 6.09615385');
      expect(dcf.toFoldedString(), '6 + (5/52) = 6.09615385');
    });
    test('01/01/2023 --> 14/01/2024', () {
      //378 days -> 54 weeks
      final dcf = dc.computeFactor(
        DateTime.utc(2023, 1, 1),
        DateTime.utc(2024, 1, 14),
      );
      expect(dcf.factor, 1.0384615384615385);
      expect(dcf.toString(), '1 + (2/52) = 1.03846154');
      expect(dcf.toFoldedString(), '1 + (2/52) = 1.03846154');
    });
    test('01/01/2023 --> 13/01/2024', () {
      //377 days -> 53 weeks + 6 days
      final dcf = dc.computeFactor(
        DateTime.utc(2023, 1, 1),
        DateTime.utc(2024, 1, 13),
      );
      expect(dcf.factor, 1.03562421185372);
      expect(dcf.toString(), '1 + (1/52) + (6/366) = 1.03562421');
      expect(dcf.toFoldedString(), '1 + (1/52) + (6/366) = 1.03562421');
    });
    test('29/12/2023 --> 05/01/2024', () {
      //1 week
      final dcf = dc.computeFactor(
        DateTime.utc(2023, 12, 29),
        DateTime.utc(2024, 1, 5),
      );
      expect(dcf.factor, 0.019230769230769232);
      expect(dcf.toString(), '(1/52) = 0.01923077');
      expect(dcf.toFoldedString(), '(1/52) = 0.01923077');
    });
    test('29/02/2024 --> 07/03/2024', () {
      //1 week
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 2, 29),
        DateTime.utc(2024, 3, 7),
      );
      expect(dcf.factor, 0.019230769230769232);
      expect(dcf.toString(), '(1/52) = 0.01923077');
      expect(dcf.toFoldedString(), '(1/52) = 0.01923077');
    });
    test('12/01/2024 --> 30/01/2024', () {
      // 18 days -> 2 + 4 days
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 1, 12),
        DateTime.utc(2024, 1, 30),
      );
      expect(dcf.factor, 0.04939050021017234);
      expect(dcf.toString(), '(2/52) + (4/366) = 0.04939050');
      expect(dcf.toFoldedString(), '(2/52) + (4/366) = 0.04939050');
    });
    test('12/01/2024 --> 12/01/2025', () {
      //366 days -> 52 weeks 2 days
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 1, 12),
        DateTime.utc(2025, 1, 12),
      );
      expect(dcf.factor, 1.0054794520547945);
      expect(dcf.toString(), '1 + (2/365) = 1.00547945');
      expect(dcf.toFoldedString(), '1 + (2/365) = 1.00547945');
    });
    test('12/01/2024 --> 12/01/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 1, 12),
        DateTime.utc(2024, 1, 12),
      );
      expect(dcf.factor, 0.0);
      expect(dcf.toString(), '0 = 0.00000000');
      expect(dcf.toFoldedString(), '0 = 0.00000000');
    });
  });
  group(
      'UKConcApp11.computeFactor '
      '[hasSingleRepayment = true, timePeriod = week]', () {
    const dc = UKConcApp11(
      hasSingleRepayment: true,
      timePeriod: DayCountTimePeriod.week,
    );
    test('timePeriod() to return week', () {
      expect(dc.timePeriod, DayCountTimePeriod.week);
    });
    test('31/01/2025 --> 28/02/2025 (whole weeks and months, use months)', () {
      // Single payment, period equal to whole weeks and months, return months
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2025, 2, 28),
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(1/12) = 0.08333333');
      expect(dcf.toFoldedString(), '(1/12) = 0.08333333');
    });
  });
  group('UKConcApp11.computeFactor [timePeriod = undefined]', () {
    const dc = UKConcApp11();
    test('hasSingleRepayment() to return FALSE by default', () {
      expect(dc.hasSingleRepayment, false);
    });
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
