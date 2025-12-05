// Test cases for USAppendixJ, based on Regulation Z, Appendix J, and adapted
// from EU200848EC tests[](https://ec.europa.eu/info/sites/info/files/guidelines_final.pdf).
// Additional cases cover Appendix J-specific rules, such as 30-day divisor for
// monthly odd days and 365-day year for daily periods.

import 'package:curo/curo.dart';
import 'package:test/test.dart';

void main() {
  group('USAppendixJ.computeFactor [timePeriod = month]', () {
    const dc = USAppendixJ(timePeriod: DayCountTimePeriod.month);
    test('timePeriod() to return month', () {
      expect(dc.timePeriod, DayCountTimePeriod.month);
    });
    test('12/01/2019 <-- 12/01/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2019, 1, 12),
        DateTime.utc(2020, 1, 12),
      );
      expect(dcf.principalFactor, closeTo(1.0, 0.00000001));
      expect(dcf.toString(), '1 = 1.00000000');
      expect(dcf.toFoldedString(), '1 = 1.00000000');
    });
    test('12/01/2012 <-- 15/02/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 2, 15),
      );
      expect(dcf.principalFactor, closeTo((1 + 3 / 30) / 12, 0.00000001));
      expect(dcf.toString(), '(1/12) + (3/30) = 0.09166667');
      expect(dcf.toFoldedString(), '(1/12) + (3/30) = 0.09166667');
    });
    test('12/01/2012 <-- 15/03/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 3, 15),
      );
      expect(dcf.principalFactor, closeTo((2 + 3 / 30) / 12, 0.00000001));
      expect(dcf.toString(), '(2/12) + (3/30) = 0.17500000');
      expect(dcf.toFoldedString(), '(2/12) + (3/30) = 0.17500000');
    });
    test('12/01/2012 <-- 15/04/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 4, 15),
      );
      expect(dcf.principalFactor, closeTo((3 + 3 / 30) / 12, 0.00000001));
      expect(dcf.toString(), '(3/12) + (3/30) = 0.25833333');
      expect(dcf.toFoldedString(), '(3/12) + (3/30) = 0.25833333');
    });
    test('25/02/2013 <-- 28/03/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2013, 2, 25),
        DateTime.utc(2013, 3, 28),
      );
      expect(dcf.principalFactor, closeTo((1 + 3 / 30) / 12, 0.00000001));
      expect(dcf.toString(), '(1/12) + (3/30) = 0.09166667');
      expect(dcf.toFoldedString(), '(1/12) + (3/30) = 0.09166667');
    });
    test('26/02/2013 <-- 29/03/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2013, 2, 26),
        DateTime.utc(2013, 3, 29),
      );
      expect(dcf.principalFactor, closeTo((1 + 3 / 30) / 12, 0.00000001));
      expect(dcf.toString(), '(1/12) + (3/30) = 0.09166667');
      expect(dcf.toFoldedString(), '(1/12) + (3/30) = 0.09166667');
    });
    test('26/02/2012 <-- 29/03/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 2, 26),
        DateTime.utc(2012, 3, 29),
      );
      expect(dcf.principalFactor, closeTo((1 + 3 / 30) / 12, 0.00000001));
      expect(dcf.toString(), '(1/12) + (3/30) = 0.09166667');
      expect(dcf.toFoldedString(), '(1/12) + (3/30) = 0.09166667');
    });
    test('26/02/2012 <-- 26/02/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 2, 26),
        DateTime.utc(2012, 2, 26),
      );
      expect(dcf.principalFactor, 0.0);
      expect(dcf.toString(), '0 = 0.00000000');
      expect(dcf.toFoldedString(), '0 = 0.00000000');
    });
    // Month-end tests
    test('30/01/2025 <-- 30/01/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 30),
        DateTime.utc(2025, 1, 30),
      );
      expect(dcf.principalFactor, 0.0);
      expect(dcf.toString(), '0 = 0.00000000');
      expect(dcf.toFoldedString(), '0 = 0.00000000');
    });
    test('31/12/2024 <-- 28/02/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 12, 31),
        DateTime.utc(2025, 2, 28),
      );
      expect(dcf.principalFactor, closeTo(2 / 12.0, 0.00000001));
      expect(dcf.toString(), '(2/12) = 0.16666667');
      expect(dcf.toFoldedString(), '(2/12) = 0.16666667');
    });
    test('28/02/2024 <-- 31/03/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 2, 28),
        DateTime.utc(2024, 3, 31),
      );
      expect(dcf.principalFactor, closeTo(1 / 12.0, 0.00000001));
      expect(dcf.toString(), '(1/12) = 0.08333333');
      expect(dcf.toFoldedString(), '(1/12) = 0.08333333');
    });
    test('29/02/2024 <-- 31/03/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 2, 29),
        DateTime.utc(2024, 3, 31),
      );
      expect(dcf.principalFactor, closeTo(1 / 12.0, 0.00000001));
      expect(dcf.toString(), '(1/12) = 0.08333333');
      expect(dcf.toFoldedString(), '(1/12) = 0.08333333');
    });
    test('31/01/2024 <-- 29/02/2024', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 1, 31),
        DateTime.utc(2024, 2, 29),
      );
      expect(dcf.principalFactor, closeTo(1 / 12.0, 0.00000001));
      expect(dcf.toString(), '(1/12) = 0.08333333');
      expect(dcf.toFoldedString(), '(1/12) = 0.08333333');
    });
    test('31/01/2024 <-- 28/02/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 1, 31),
        DateTime.utc(2025, 2, 28),
      );
      expect(dcf.principalFactor, closeTo((12 + 1) / 12.0, 0.00000001));
      expect(dcf.toString(), '1 + (1/12) = 1.08333333');
      expect(dcf.toFoldedString(), '1 + (1/12) = 1.08333333');
    });
    // Appendix J-specific test
    test('10/01/2026 <-- 01/03/2026', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 3, 1),
      );
      expect(dcf.principalFactor, closeTo((1 + 22 / 30) / 12, 0.00000001));
      expect(dcf.toString(), '(1/12) + (22/30) = 0.14444444');
      expect(dcf.toFoldedString(), '(1/12) + (22/30) = 0.14444444');
    });
  });

  group('USAppendixJ.computeFactor [timePeriod = year]', () {
    const dc = USAppendixJ(timePeriod: DayCountTimePeriod.year);
    test('timePeriod() to return year', () {
      expect(dc.timePeriod, DayCountTimePeriod.year);
    });
    test('12/01/2012 <-- 15/02/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 2, 15),
      );
      expect(dcf.principalFactor, closeTo(34 / 365.0, 0.00000001));
      expect(dcf.toString(), '(34/365) = 0.09315068');
      expect(dcf.toFoldedString(), '(34/365) = 0.09315068');
    });
    test('12/01/2012 <-- 15/02/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2013, 2, 15),
      );
      expect(dcf.principalFactor, closeTo(1 + 34 / 365.0, 0.00000001));
      expect(dcf.toString(), '1 + (34/365) = 1.09315068');
      expect(dcf.toFoldedString(), '1 + (34/365) = 1.09315068');
    });
    test('12/01/2012 <-- 15/02/2014', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2014, 2, 15),
      );
      expect(dcf.principalFactor, closeTo(2 + 34 / 365.0, 0.00000001));
      expect(dcf.toString(), '2 + (34/365) = 2.09315068');
      expect(dcf.toFoldedString(), '2 + (34/365) = 2.09315068');
    });
    test('01/01/2020 <-- 15/03/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2021, 3, 15),
      );
      expect(dcf.principalFactor, closeTo(1 + 74 / 365.0, 0.00000001));
      expect(dcf.toString(), '1 + (74/365) = 1.20273973');
      expect(dcf.toFoldedString(), '1 + (74/365) = 1.20273973');
    });
    test('01/01/2020 <-- 01/01/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 1),
      );
      expect(dcf.principalFactor, 0.0);
      expect(dcf.toString(), '0 = 0.00000000');
      expect(dcf.toFoldedString(), '0 = 0.00000000');
    });
    // Month-end tests
    test('30/01/2025 <-- 30/01/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2025, 1, 30),
        DateTime.utc(2025, 1, 30),
      );
      expect(dcf.principalFactor, 0.0);
      expect(dcf.toString(), '0 = 0.00000000');
      expect(dcf.toFoldedString(), '0 = 0.00000000');
    });
    test('27/02/2024 <-- 28/02/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 2, 27),
        DateTime.utc(2025, 2, 28),
      );
      expect(dcf.principalFactor, closeTo(1 + 1 / 365.0, 0.00000001));
      expect(dcf.toString(), '1 + (1/365) = 1.00273973');
      expect(dcf.toFoldedString(), '1 + (1/365) = 1.00273973');
    });
    test('29/02/2024 <-- 31/03/2025', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2024, 2, 29),
        DateTime.utc(2025, 3, 31),
      );
      expect(dcf.principalFactor, closeTo(1 + 31 / 365.0, 0.00000001));
      expect(dcf.toString(), '1 + (31/365) = 1.08493151');
      expect(dcf.toFoldedString(), '1 + (31/365) = 1.08493151');
    });
  });

  group('USAppendixJ.computeFactor [timePeriod = week]', () {
    const dc = USAppendixJ(timePeriod: DayCountTimePeriod.week);
    test('timePeriod() to return week', () {
      expect(dc.timePeriod, DayCountTimePeriod.week);
    });
    test('12/01/2012 <-- 26/01/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 1, 26),
      );
      expect(dcf.principalFactor, closeTo(2 / 52.0, 0.00000001));
      expect(dcf.toString(), '(2/52) = 0.03846154');
      expect(dcf.toFoldedString(), '(2/52) = 0.03846154');
    });
    test('12/01/2012 <-- 10/01/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2013, 1, 10),
      );
      expect(dcf.principalFactor, closeTo(1 + 2 / 365.0, 0.00000001));
      expect(dcf.toString(), '1 + (2/365) = 1.00547945');
      expect(dcf.toFoldedString(), '1 + (2/365) = 1.00547945');
    });
    test('12/01/2012 <-- 30/01/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 1, 30),
      );
      expect(dcf.principalFactor, closeTo((2 + 4 / 365.0) / 52, 0.00000001));
      expect(dcf.toString(), '(2/52) + (4/365) = 0.04942044');
      expect(dcf.toFoldedString(), '(2/52) + (4/365) = 0.04942044');
    });
    test('12/01/2012 <-- 12/01/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2013, 1, 12),
      );
      expect(dcf.principalFactor, closeTo(1 + 2 / 365.0, 0.00000001));
      expect(dcf.toString(), '1 + (2/365) = 1.00547945');
      expect(dcf.toFoldedString(), '1 + (2/365) = 1.00547945');
    });
    test('12/01/2012 <-- 12/01/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 1, 12),
      );
      expect(dcf.principalFactor, 0.0);
      expect(dcf.toString(), '0 = 0.00000000');
      expect(dcf.toFoldedString(), '0 = 0.00000000');
    });
  });

  group('USAppendixJ.computeFactor [timePeriod = day]', () {
    const dc = USAppendixJ(timePeriod: DayCountTimePeriod.day);
    test('timePeriod() to return day', () {
      expect(dc.timePeriod, DayCountTimePeriod.day);
    });
    test('01/01/2026 <-- 15/02/2026', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2026, 2, 15),
      );
      expect(dcf.principalFactor, closeTo(45 / 365.0, 0.00000001));
      expect(dcf.toString(), '(45/365) = 0.12328767');
      expect(dcf.toFoldedString(), '(45/365) = 0.12328767');
    });
    test('10/01/2026 <-- 01/03/2026', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 3, 1),
      );
      expect(dcf.principalFactor, closeTo(50 / 365.0, 0.00000001));
      expect(dcf.toString(), '(50/365) = 0.13698630');
      expect(dcf.toFoldedString(), '(50/365) = 0.13698630');
    });
    test('01/01/2020 <-- 01/01/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 1),
      );
      expect(dcf.principalFactor, 0.0);
      expect(dcf.toString(), '0 = 0.00000000');
      expect(dcf.toFoldedString(), '0 = 0.00000000');
    });
  });

  group('USAppendixJ.computeFactor [timePeriod = undefined]', () {
    const dc = USAppendixJ();
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

  // Placeholder for end-to-end APR tests
  // TODO add more end-to-end tests, including solving for unknown cashflow values
  group('USAppendixJ APR Calculation', () {
    test('Solve APR: Single advance, 12 monthly payments', () async {
      final calculator = Calculator();
      calculator.add(
        SeriesAdvance(
          label: 'Loan',
          value: 10000,
          postDateFrom: utcDate(DateTime(2026, 1, 10)),
        ),
      );
      calculator.add(
        SeriesPayment(
          numberOf: 12,
          label: 'Instalment',
          value: 884.91,
          frequency: Frequency.monthly,
          postDateFrom: utcDate(DateTime(2026, 2, 15)),
        ),
      );
      calculator.add(
        SeriesCharge(
          numberOf: 1,
          label: 'Fee',
          value: 200.0,
          postDateFrom: utcDate(DateTime(2026, 1, 10)),
        ),
      );
      final apr = await calculator.solveRate(
         dayCount: const USAppendixJ(timePeriod: DayCountTimePeriod.month),
      );
      expect(apr, closeTo(0.14692, 0.01)); // Validated with FFIEC APR tool
    });
    test('Solve Unknown Payment using APR: Single advance, 12 monthly payments', () async {
      final calculator = Calculator();
      calculator.add(
        SeriesAdvance(
          label: 'Loan',
          value: 10000,
          postDateFrom: utcDate(DateTime(2026, 1, 10)),
        ),
      );
      calculator.add(
        SeriesPayment(
          numberOf: 12,
          label: 'Instalment',
          value: null,
          frequency: Frequency.monthly,
          postDateFrom: utcDate(DateTime(2026, 2, 15)),
        ),
      );
      calculator.add(
        SeriesCharge(
          numberOf: 1,
          label: 'Fee',
          value: 200.0,
          postDateFrom: utcDate(DateTime(2026, 1, 10)),
        ),
      );
      final payment = await calculator.solveValue(
         dayCount: const USAppendixJ(),
         interestRate: 0.14692,
      );
      expect(payment, closeTo(884.91, 0.01));
    });
  });
}
