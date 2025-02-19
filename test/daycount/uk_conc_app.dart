import 'package:curo/src/daycount/day_count_origin.dart';
import 'package:curo/src/daycount/day_count_time_period.dart';
import 'package:curo/src/daycount/uk_conc_app.dart';
import 'package:test/test.dart';

void main() {
  group('UKConcApp.computeFactor [isSecuredOnLand = false, timePeriod = month]',
      () {
    // App 1.2: Non-secured, month frequency
    const dc = UKConcApp(timePeriod: DayCountTimePeriod.month);
    test('timePeriod() returns month', () {
      expect(dc.timePeriod, DayCountTimePeriod.month);
    });
    test('31/01/2025 --> 28/02/2025 (whole months)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2025, 1, 31), DateTime.utc(2025, 2, 28));
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(1/12) = 0.08333333');
    });
    test('12/01/2025 --> 15/02/2025 (non-whole)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2025, 1, 12), DateTime.utc(2025, 2, 15));
      expect(dcf.factor, 0.0915525114155251);
      expect(dcf.toString(), '(1/12) + (3/365) = 0.09155251');
    });
    test('15/12/2023 --> 29/02/2024 (cross-year, leap)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2023, 12, 15), DateTime.utc(2024, 2, 29));
      expect(dcf.factor, 0.20491803278688525);
      expect(dcf.toString(), '(2/12) + (14/366) = 0.20491803');
    });
    test('26/02/2025 --> 26/02/2025 (zero days)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2025, 2, 26), DateTime.utc(2025, 2, 26));
      expect(dcf.factor, 0.0);
      expect(dcf.toString(), '0 = 0.00000000');
    });
  });
  group('UKConcApp.computeFactor [isSecuredOnLand = false, timePeriod = week]',
      () {
    // App 1.2: Non-secured, week frequency
    const dc = UKConcApp(timePeriod: DayCountTimePeriod.week);
    test('timePeriod() returns week', () {
      expect(dc.timePeriod, DayCountTimePeriod.week);
    });
    test('31/01/2025 --> 28/02/2025 (whole weeks)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2025, 1, 31), DateTime.utc(2025, 2, 28));
      expect(dcf.factor, 0.07692307692307693);
      expect(dcf.toString(), '(4/52) = 0.07692308');
    });
    test('01/01/2023 --> 14/01/2024 (whole weeks, cross-year)', () {
      final dcf =
          dc.computeFactor(DateTime.utc(2023, 1, 1), DateTime.utc(2024, 1, 14));
      expect(dcf.factor, 1.0384615384615385);
      expect(dcf.toString(), '1 + (2/52) = 1.03846154');
    });
    test('12/01/2024 --> 30/01/2024 (non-whole)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2024, 1, 12), DateTime.utc(2024, 1, 30));
      expect(dcf.factor, 0.04939050021017234);
      expect(dcf.toString(), '(2/52) + (4/366) = 0.04939050');
    });
  });
  group(
      'UKConcApp.computeFactor '
      '[isSecuredOnLand = true, hasSinglePayment = false, timePeriod = month]',
      () {
    // App 1.1: Secured, month frequency, multiple payments
    const dc =
        UKConcApp(isSecuredOnLand: true, timePeriod: DayCountTimePeriod.month);
    test('31/01/2025 --> 28/02/2025 (whole months)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2025, 1, 31), DateTime.utc(2025, 2, 28));
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(1/12) = 0.08333333');
    });
    test('31/01/2025 --> 28/02/2029 (multiple years)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2025, 1, 31), DateTime.utc(2031, 2, 28));
      expect(dcf.factor, 6.08333333333333333);
      expect(dcf.toString(), '6 + (1/12) = 6.08333333');
    });
    test('12/12/2024 --> 15/02/2025 (non-whole)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2024, 12, 12), DateTime.utc(2025, 2, 15));
      expect(dcf.factor, 0.17488584474885843);
      expect(dcf.toString(), '(2/12) + (3/365) = 0.17488584');
    });
  });
  group(
      'UKConcApp.computeFactor '
      '[isSecuredOnLand = true, hasSinglePayment = false, timePeriod = week]',
      () {
    // App 1.1: Secured, week frequency, multiple payments
    const dc =
        UKConcApp(isSecuredOnLand: true, timePeriod: DayCountTimePeriod.week);
    test('31/01/2025 --> 28/02/2025 (edge case, weeks)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2025, 1, 31), DateTime.utc(2025, 2, 28));
      expect(dcf.factor, 0.07692307692307693);
      expect(dcf.toString(), '(4/52) = 0.07692308');
    });
    test('31/01/2025 --> 28/02/2031 (long period, weeks)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2025, 1, 31), DateTime.utc(2031, 2, 28));
      expect(dcf.factor, 6.096153846153846);
      expect(dcf.toString(), '6 + (5/52) = 6.09615385');
    });
    test('29/02/2024 --> 07/03/2024 (leap year, week)', () {
      final dcf =
          dc.computeFactor(DateTime.utc(2024, 2, 29), DateTime.utc(2024, 3, 7));
      expect(dcf.factor, 0.019230769230769232);
      expect(dcf.toString(), '(1/52) = 0.01923077');
    });
  });
  group(
      'UKConcApp.computeFactor '
      '[isSecuredOnLand = true, hasSinglePayment = true, timePeriod = week]',
      () {
    // App 1.1: Secured, week frequency, single payment
    const dc = UKConcApp(
      isSecuredOnLand: true,
      hasSinglePayment: true,
      timePeriod: DayCountTimePeriod.week,
    );
    test('31/01/2025 --> 28/02/2025 (edge case, months override)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2025, 1, 31), DateTime.utc(2025, 2, 28));
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(1/12) = 0.08333333');
    });
    test('31/01/2024 --> 29/02/2024 (leap year, non-whole)', () {
      final dcf = dc.computeFactor(
          DateTime.utc(2024, 1, 31), DateTime.utc(2024, 2, 29));
      expect(dcf.factor, 0.0796553173602354);
      expect(dcf.toString(), '(4/52) + (1/366) = 0.07965532');
    });
  });
  group('UKConcApp Defaults and properties', () {
    const dc = UKConcApp();
    test('isSecuredOnLand defaults to false', () {
      expect(dc.isSecuredOnLand, false);
    });
    test('hasSinglePayment defaults to false', () {
      expect(dc.hasSinglePayment, false);
    });
    test('timePeriod defaults to month', () {
      expect(dc.timePeriod, DayCountTimePeriod.month);
    });
    test('dayCountOrigin returns drawdown', () {
      expect(dc.dayCountOrigin(), DayCountOrigin.drawdown);
    });
    test('usePostDates returns true', () {
      expect(dc.usePostDates, true);
    });
    test('includeNonFinancingFlows returns true', () {
      expect(dc.includeNonFinancingFlows, true);
    });
  });
}
