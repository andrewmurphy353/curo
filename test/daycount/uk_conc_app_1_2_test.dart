import 'package:curo/src/daycount/day_count_origin.dart';
import 'package:curo/src/daycount/day_count_time_period.dart';
import 'package:curo/src/daycount/uk_conc_app_1_2.dart';
import 'package:test/test.dart';

void main() {
  group('UKConcApp12.computeFactor [timePeriod = week]', () {
    const dc = UKConcApp12(timePeriod: DayCountTimePeriod.week);
    test('timePeriod() to return week', () {
      expect(dc.timePeriod, DayCountTimePeriod.week);
    });
    test('31/01/2025 --> 28/02/2025 (4 whole weeks)', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2025, 2, 28),
      );
      expect(dcf.factor, 0.07692307692307693);
      expect(dcf.toString(), '(4/52) = 0.07692308');
      expect(dcf.toFoldedString(), '(4/52) = 0.07692308');
    });
    test('31/01/2025 --> 31/01/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2025, 1, 31),
      );
      expect(dcf.factor, 0.00000000000000000);
      expect(dcf.toString(), '0 = 0.00000000');
      expect(dcf.toFoldedString(), '0 = 0.00000000');
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
      //377 days -> 364/365 + 13/366
      final dcf = dc.computeFactor(
        DateTime.utc(2023, 1, 1),
        DateTime.utc(2024, 1, 13),
      );
      expect(dcf.factor, 1.032779399655663);
      expect(dcf.toString(), '(364/365) + (13/366) = 1.03277940');
      expect(dcf.toFoldedString(), '(364/365) + (13/366) = 1.03277940');
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
      // 18 days
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 1, 12),
        DateTime.utc(2024, 1, 30),
      );
      expect(dcf.factor, 0.04918032786885246);
      expect(dcf.toString(), '(18/366) = 0.04918033');
      expect(dcf.toFoldedString(), '(18/366) = 0.04918033');
    });
    test('12/01/2024 --> 12/01/2025', () {
      //366 days -> 354/366 12/365
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 1, 12),
        DateTime.utc(2025, 1, 12),
      );
      expect(dcf.factor, 1.0000898270828655);
      expect(dcf.toString(), '(354/366) + (12/365) = 1.00008983');
      expect(dcf.toFoldedString(), '(354/366) + (12/365) = 1.00008983');
    });
  });

  group('UKConcApp12.computeFactor [timePeriod = month]', () {
    const dc = UKConcApp12(timePeriod: DayCountTimePeriod.month);
    test('timePeriod() to return month', () {
      expect(dc.timePeriod, DayCountTimePeriod.month);
    });
    test('12/01/2025 --> 15/02/2025', () {
      //34 days
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 12),
        DateTime.utc(2025, 2, 15),
      );
      expect(dcf.factor, 0.09315068493150686);
      expect(dcf.toString(), '(34/365) = 0.09315068');
      expect(dcf.toFoldedString(), '(34/365) = 0.09315068');
    });
    test('15/01/2025 --> 12/02/2025', () {
      // 28 days
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
      expect(dcf.factor, 0.1779399655662849);
      expect(dcf.toString(), '(19/366) + (46/365) = 0.17793997');
      expect(dcf.toFoldedString(), '(19/366) + (46/365) = 0.17793997');
    });
    test('15/12/2023 --> 29/02/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2023, 12, 15),
        DateTime.utc(2024, 2, 29),
      );
      expect(dcf.factor, 0.20777004266786436);
      expect(dcf.toString(), '(16/365) + (60/366) = 0.20777004');
      expect(dcf.toFoldedString(), '(16/365) + (60/366) = 0.20777004');
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
      expect(dcf.factor, 0.08743169398907104);
      expect(dcf.toString(), '(32/366) = 0.08743169');
      expect(dcf.toFoldedString(), '(32/366) = 0.08743169');
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
      expect(dcf.factor, 0.08743169398907104);
      expect(dcf.toString(), '(32/366) = 0.08743169');
      expect(dcf.toFoldedString(), '(32/366) = 0.08743169');
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
    test('31/01/2024 --> 29/02/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 1, 31),
        DateTime.utc(2024, 2, 29),
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(1/12) = 0.08333333');
      expect(dcf.toFoldedString(), '(1/12) = 0.08333333');
    });
    test('31/01/2024 --> 28/02/2025', () {
      // 13 whole months
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 1, 31),
        DateTime.utc(2025, 2, 28),
      );
      expect(dcf.factor, 1.08333333333333333);
      expect(dcf.toString(), '1 + (1/12) = 1.08333333');
      expect(dcf.toFoldedString(), '1 + (1/12) = 1.08333333');
    });
    test('30/11/2024 --> 28/02/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2023, 11, 30),
        DateTime.utc(2025, 2, 28),
      );
      expect(dcf.factor, 1.25000000000000000);
      expect(dcf.toString(), '1 + (3/12) = 1.25000000');
      expect(dcf.toFoldedString(), '1 + (3/12) = 1.25000000');
    });
    test('15/01/2023 --> 01/03/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2023, 1, 15),
        DateTime.utc(2025, 3, 1),
      );
      expect(dcf.factor, 2.1232876712328768);
      expect(dcf.toString(), '(350/365) + 1 + (60/365) = 2.12328767');
      expect(dcf.toFoldedString(), '(350/365) + 1 + (60/365) = 2.12328767');
    });
  });

  group('UKConcApp12.computeFactor [timePeriod = year]', () {
    const dc = UKConcApp12(timePeriod: DayCountTimePeriod.year);
    test('timePeriod() to return year', () {
      expect(dc.timePeriod, DayCountTimePeriod.year);
    });
    test('31/01/2025 --> 31/01/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2025, 1, 31),
      );
      expect(dcf.factor, 0.00000000000000000);
      expect(dcf.toString(), '0 = 0.00000000');
      expect(dcf.toFoldedString(), '0 = 0.00000000');
    });
    test('31/01/2025 --> 31/01/2026 (1 year)', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2026, 1, 31),
      );
      expect(dcf.factor, 1.00000000000000000);
      expect(dcf.toString(), '1 = 1.00000000');
      expect(dcf.toFoldedString(), '1 = 1.00000000');
    });
    test('31/01/2025 --> 28/02/2026 (1 year 28 days)', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2026, 2, 28),
      );
      expect(dcf.factor, 1.0767123287671234);
      expect(dcf.toString(), '(334/365) + (59/365) = 1.07671233');
      expect(dcf.toFoldedString(), '(334/365) + (59/365) = 1.07671233');
    });
    test('15/01/2025 --> 12/02/2025', () {
      // 28 days
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 15),
        DateTime.utc(2025, 2, 12),
      );
      expect(dcf.factor, 0.07671232876712329);
      expect(dcf.toString(), '(28/365) = 0.07671233');
      expect(dcf.toFoldedString(), '(28/365) = 0.07671233');
    });
    test('01/01/2025 --> 10/01/2028', () {
      // 3 years 9 days
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 1),
        DateTime.utc(2028, 1, 10),
      );
      expect(dcf.factor, 3.024582678344187);
      expect(dcf.toString(), '(364/365) + 1 + 1 + (10/366) = 3.02458268');
      expect(dcf.toFoldedString(), '(364/365) + 2 + (10/366) = 3.02458268');
    });
  });

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
