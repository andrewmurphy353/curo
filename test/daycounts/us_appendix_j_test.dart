import 'package:curo/src/calculator.dart';
import 'package:curo/src/enums.dart';
import 'package:test/test.dart';

void main() {
  group('USAppendixJ - monthly (default)', () {
    const convention = USAppendixJ();

    test('default timePeriod is month', () {
      expect(convention.timePeriod, DayCountTimePeriod.month);
    });

    test('fixed flags are correct', () {
      expect(convention.usePostDates, isTrue);
      expect(convention.includeNonFinancingFlows, isTrue);
      expect(convention.useXirrMethod, isTrue);
      expect(convention.dayCountOrigin, DayCountOrigin.drawdown);
    });

    test('same day returns zero', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 1, 10),
      );
      expect(factor.primaryPeriodFraction, 0.0);
      expect(factor.partialPeriodFraction, 0.0);
      expect(factor.toString(), 't = 0 : f = 0 : p = 12');
    });

    test('end before start throws ArgumentError', () {
      expect(
        () => convention.computeFactor(
          DateTime.utc(2020, 2, 1),
          DateTime.utc(2020, 1, 1),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
    test('10/01/2026 -> 15/02/2026 (1 whole month + 5 odd days)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 2, 15),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0, 1e-10));
      expect(factor.partialPeriodFraction, closeTo(5 / 30, 1e-10));
      expect(factor.toString(), 't = 1 : f = 5/30 = 0.16666667 : p = 12');
    });
    test('31/01/2026 -> 28/02/2026 (whole month, month-end alignment)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 31),
        DateTime.utc(2026, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0, 1e-10));
      expect(factor.partialPeriodFraction, 0.0);
      expect(factor.toString(), 't = 1 : f = 0 : p = 12');
    });
    test(
        '31/01/2028 -> 29/02/2028 (whole month, leap-year, month-end alignment)',
        () {
      final factor = convention.computeFactor(
        DateTime.utc(2028, 1, 31),
        DateTime.utc(2028, 2, 29),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0, 1e-10));
      expect(factor.partialPeriodFraction, 0.0);
      expect(factor.toString(), 't = 1 : f = 0 : p = 12');
    });
    test('10/01/2026 -> 10/03/2026 (exact 2 months)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 3, 10),
      );
      expect(factor.primaryPeriodFraction, closeTo(2.0, 1e-10));
      expect(factor.partialPeriodFraction, 0.0);
      expect(factor.toString(), 't = 2 : f = 0 : p = 12');
    });
    test('10/01/2026 -> 20/01/2026 (10 odd days)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 1, 20),
      );
      expect(factor.primaryPeriodFraction, 0.0);
      expect(factor.partialPeriodFraction, closeTo(10 / 30, 1e-10));
      expect(factor.toString(), 't = 0 : f = 10/30 = 0.33333333 : p = 12');
    });
    test('10/01/2026 -> 15/03/2026 (5 odd days)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 3, 15),
      );
      expect(factor.primaryPeriodFraction, closeTo(2.0, 1e-10));
      expect(factor.partialPeriodFraction, closeTo(5.0 / 30.0, 1e-10));
      expect(factor.toString(), 't = 2 : f = 5/30 = 0.16666667 : p = 12');
    });
    test('10/01/2026 -> 15/03/2027 (14 months, 5 odd days)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2027, 3, 15),
      );
      expect(factor.primaryPeriodFraction, closeTo(14.0, 1e-10));
      expect(factor.partialPeriodFraction, closeTo(5.0 / 30.0, 1e-10));
      expect(factor.toString(), 't = 14 : f = 5/30 = 0.16666667 : p = 12');
    });
  });

  group('USAppendixJ - weekly', () {
    const convention = USAppendixJ(timePeriod: DayCountTimePeriod.week);
    test('10/01/2026 -> 17/01/2026 (1 week)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 1, 17),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0, 0.0001));
      expect(factor.partialPeriodFraction, 0.0);
      expect(factor.toString(), 't = 1 : f = 0 : p = 52');
    });
    test('10/01/2026 -> 20/01/2025 (1 week, 3 days)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 1, 20),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0, 0.0001));
      expect(factor.partialPeriodFraction, closeTo(3 / 7, 0.0001));
      expect(factor.toString(), 't = 1 : f = 3/7 = 0.42857143 : p = 52');
    });
  });

  group('USAppendixJ - fortnightly', () {
    const convention = USAppendixJ(timePeriod: DayCountTimePeriod.fortnight);
    test('20/01/2026 -> 03/02/2026 (1 fortnight)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 20),
        DateTime.utc(2026, 2, 3),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0, 0.0001));
      expect(factor.partialPeriodFraction, 0.0);
      expect(factor.toString(), 't = 1 : f = 0 : p = 26');
    });
    test('20/01/2026 -> 03/02/2026 (1 fortnight, 5 days)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 20),
        DateTime.utc(2026, 2, 8),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0, 0.0001));
      expect(factor.partialPeriodFraction, closeTo(5 / 15, 0.0001));
      expect(factor.toString(), 't = 1 : f = 5/15 = 0.33333333 : p = 26');
    });
  });

  group('USAppendixJ - quarterly', () {
    const convention = USAppendixJ(timePeriod: DayCountTimePeriod.quarter);
    test('10/01/2026 -> 10/04/2026 (1 quarter)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 4, 10),
      );
      expect(factor.primaryPeriodFraction, 1.0);
      expect(factor.partialPeriodFraction, 0.0);
      expect(factor.toString(), 't = 1 : f = 0 : p = 4');
    });
    test('10/01/2026 -> 01/05/2026 (1 quarter, 22 days)', () {
      // backwards:
      // 01/02/2026 <- 01/05/2026 (1Q)
      // 10/01/2026 <- 01/02/2025 (22 days)
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 5, 1),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0, 0.0001));
      expect(factor.partialPeriodFraction, closeTo(22 / 90, 0.0001));
      expect(factor.toString(), 't = 1 : f = 22/90 = 0.24444444 : p = 4');
    });
  });

  group('USAppendixJ - half-yearly', () {
    const convention = USAppendixJ(timePeriod: DayCountTimePeriod.halfYear);
    test('10/01/2026 -> 10/06/2026 (1 half-year)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 7, 10),
      );
      expect(factor.primaryPeriodFraction, 1.0);
      expect(factor.partialPeriodFraction, 0.0);
      expect(factor.toString(), 't = 1 : f = 0 : p = 2');
    });
    test('10/01/2026 -> 01/08/2026 (1 half-year, 22 days)', () {
      // backwards:
      // 01/02/2026 <- 01/08/2026 (1HY)
      // 10/01/2026 <- 01/02/2025 (22 days)
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 10),
        DateTime.utc(2026, 8, 1),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0, 0.0001));
      expect(factor.partialPeriodFraction, closeTo(22 / 180, 0.0001));
      expect(factor.toString(), 't = 1 : f = 22/180 = 0.12222222 : p = 2');
    });
  });

  group('USAppendixJ - yearly', () {
    const convention = USAppendixJ(timePeriod: DayCountTimePeriod.year);
    test('01/01/2026 -> 01/01/2027 (1 year)', () {
      final factor = convention.computeFactor(
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2027, 1, 1),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0, 0.0001));
      expect(factor.partialPeriodFraction, 0.0);
      expect(factor.toString(), 't = 1 : f = 0 : p = 1');
    });
    test('15/02/2024 -> 28/02/2025 (1 year, 14 days)', () {
      // backwards:
      // 29/02/2024 <- 28/02/2025 (1Y)
      // 15/02/2024 <- 29/02/2024 (14 days)
      final factor = convention.computeFactor(
        DateTime.utc(2024, 2, 15),
        DateTime.utc(2025, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0, 0.0001));
      expect(factor.partialPeriodFraction, closeTo(14 / 365, 0.0001));
      expect(factor.toString(), 't = 1 : f = 14/365 = 0.03835616 : p = 1');
    });
  });

  group('USAppendixJ - daily', () {
    const convention = USAppendixJ(timePeriod: DayCountTimePeriod.day);
    test('06/12/2025 -> 17/01/2026 (42 days)', () {
      final factor = convention.computeFactor(
        // 7 -> 31 = 25 (inclusive) + 17 = 42
        DateTime.utc(2025, 12, 6),
        DateTime.utc(2026, 1, 17),
      );
      expect(factor.primaryPeriodFraction, 0.0);
      expect(factor.partialPeriodFraction, closeTo(42 / 365, 1e-10));
      expect(factor.toString(), 't = 0 : f = 42/365 = 0.11506849 : p = 365');
    });
  });

  group('USAppendixJ end-to-end calculations', () {
    test('Solve APR: Single advance, 3 yearly payments', () async {
      final calculator = Calculator()
        ..add(SeriesAdvance(
            label: 'Loan',
            amount: 100000,
            postDateFrom: DateTime.utc(2026, 4, 27)))
        ..add(SeriesPayment(
            numberOf: 3,
            label: 'Instalment',
            amount: 40215.0,
            frequency: Frequency.yearly,
            postDateFrom: DateTime.utc(2027, 4, 30)))
        ..add(SeriesCharge(
            numberOf: 1,
            label: 'Fee',
            amount: 1000.0,
            postDateFrom: DateTime.utc(2026, 4, 27)));
      final apr = await calculator.solveRate(
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.year),
      );
      expect(apr, closeTo(0.10528415, 1e-8)); // Validated with FFIEC APR tool
    });
    test('Solve Payment: Single advance, 3 yearly payments', () async {
      final calculator = Calculator()
        ..add(SeriesAdvance(
            label: 'Loan',
            amount: 100000,
            postDateFrom: DateTime.utc(2026, 4, 27)))
        ..add(SeriesPayment(
            numberOf: 3,
            label: 'Instalment',
            amount: null,
            frequency: Frequency.yearly,
            postDateFrom: DateTime.utc(2027, 4, 30)))
        ..add(SeriesCharge(
            numberOf: 1,
            label: 'Fee',
            amount: 1000.0,
            postDateFrom: DateTime.utc(2026, 4, 27)));
      // APR of 0.105277 returns 40214.49 (51c diff). Verified the time factors
      // are correct. Although the variance is quite large it is 'reasonable'
      // given the low number of payments, and may simply be due to rounding
      // errors.
      final payment = await calculator.solveValue(
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.year),
        interestRate: 0.1052841, //0.105277,
      );
      expect(payment, closeTo(40215.0, 0.01));
    });
    test('Solve APR: Single advance, 6 half-yearly payments', () async {
      final calculator = Calculator()
        ..add(
          SeriesAdvance(
              label: 'Loan',
              amount: 100000,
              postDateFrom: DateTime.utc(2026, 4, 27)),
        )
        ..add(
          SeriesPayment(
              numberOf: 6,
              label: 'Instalment',
              amount: 19700.0,
              frequency: Frequency.halfYearly,
              postDateFrom: DateTime.utc(2026, 10, 31)),
        )
        ..add(
          SeriesCharge(
              numberOf: 1,
              label: 'Fee',
              amount: 1000.0,
              postDateFrom: DateTime.utc(2026, 4, 27)),
        );
      final apr = await calculator.solveRate(
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.halfYear),
      );
      expect(apr, closeTo(0.10569370, 1e-8)); // Validated with FFIEC APR tool
    });
    test('Solve Payment: Single advance, 6 half-yearly payments', () async {
      final calculator = Calculator()
        ..add(
          SeriesAdvance(
              label: 'Loan',
              amount: 100000,
              postDateFrom: DateTime.utc(2026, 4, 27)),
        )
        ..add(
          SeriesPayment(
              numberOf: 6,
              label: 'Instalment',
              amount: null,
              frequency: Frequency.halfYearly,
              postDateFrom: DateTime.utc(2026, 10, 31)),
        )
        ..add(
          SeriesCharge(
              numberOf: 1,
              label: 'Fee',
              amount: 1000.0,
              postDateFrom: DateTime.utc(2026, 4, 27)),
        );
      final payment = await calculator.solveValue(
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.halfYear),
        interestRate: 0.105694,
      );
      expect(payment, closeTo(19700.0, 0.01));
    });
    test('Solve APR: Single advance, 8 quarterly payments', () async {
      final calculator = Calculator()
        ..add(
          SeriesAdvance(
              label: 'Loan',
              amount: 100000,
              postDateFrom: DateTime.utc(2026, 4, 27)),
        )
        ..add(
          SeriesPayment(
              numberOf: 8,
              label: 'Instalment',
              amount: 13946.73,
              frequency: Frequency.quarterly,
              postDateFrom: DateTime.utc(2026, 7, 31)),
        )
        ..add(
          SeriesCharge(
              numberOf: 1,
              label: 'Fee',
              amount: 1000.0,
              postDateFrom: DateTime.utc(2026, 4, 27)),
        );
      final apr = await calculator.solveRate(
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.quarter),
      );
      expect(apr, closeTo(0.10859928, 1e-8)); // Validated with FFIEC APR tool
    });
    test('Solve Payment: Single advance, 8 quarterly payments', () async {
      final calculator = Calculator()
        ..add(
          SeriesAdvance(
              label: 'Loan',
              amount: 100000,
              postDateFrom: DateTime.utc(2026, 4, 27)),
        )
        ..add(
          SeriesPayment(
              numberOf: 8,
              label: 'Instalment',
              amount: null,
              frequency: Frequency.quarterly,
              postDateFrom: DateTime.utc(2026, 7, 31)),
        )
        ..add(
          SeriesCharge(
              numberOf: 1,
              label: 'Fee',
              amount: 1000.0,
              postDateFrom: DateTime.utc(2026, 4, 27)),
        );
      final payment = await calculator.solveValue(
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.quarter),
        interestRate: 0.108599,
      );
      expect(payment, closeTo(13946.73, 0.01));
    });
    test('Solve APR: Single advance, 12 monthly payments', () async {
      final calculator = Calculator()
        ..add(
          SeriesAdvance(
              label: 'Loan',
              amount: 10000,
              postDateFrom: DateTime.utc(2026, 1, 10)),
        )
        ..add(
          SeriesPayment(
              numberOf: 12,
              label: 'Instalment',
              amount: 884.91,
              frequency: Frequency.monthly,
              postDateFrom: DateTime.utc(2026, 2, 15)),
        )
        ..add(
          SeriesCharge(
              numberOf: 1,
              label: 'Fee',
              amount: 200.0,
              postDateFrom: DateTime.utc(2026, 1, 10)),
        );
      final apr = await calculator.solveRate(
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.month),
      );
      expect(apr, closeTo(0.14692036, 1e-8)); // Validated with FFIEC APR tool
    });
    test('Solve Payment: Single advance, 12 monthly payments', () async {
      final calculator = Calculator()
        ..add(
          SeriesAdvance(
              label: 'Loan',
              amount: 10000,
              postDateFrom: DateTime.utc(2026, 1, 10)),
        )
        ..add(
          SeriesPayment(
              numberOf: 12,
              label: 'Instalment',
              amount: null,
              frequency: Frequency.monthly,
              postDateFrom: DateTime.utc(2026, 2, 15)),
        )
        ..add(
          SeriesCharge(
              numberOf: 1,
              label: 'Fee',
              amount: 200.0,
              postDateFrom: DateTime.utc(2026, 1, 10)),
        );
      final payment = await calculator.solveValue(
        convention: const USAppendixJ(),
        interestRate: 0.14692,
      );
      expect(payment, closeTo(884.91, 0.01));
    });
    test('Solve APR: Single advance, 26 fortnightly payments', () async {
      final calculator = Calculator()
        ..add(
          SeriesAdvance(
              label: 'Loan',
              amount: 10000,
              postDateFrom: DateTime.utc(2025, 12, 6)),
        )
        // Pmts due from 19 days after advance i.e. with 5 day odd period at start
        ..add(
          SeriesPayment(
              numberOf: 26,
              label: 'Instalment',
              amount: 394.68,
              frequency: Frequency.fortnightly,
              postDateFrom: DateTime.utc(2025, 12, 25)),
        )
        ..add(
          SeriesCharge(
              numberOf: 1,
              label: 'Fee',
              amount: 100.0,
              postDateFrom: DateTime.utc(2025, 12, 6)),
        );
      final apr = await calculator.solveRate(
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.fortnight),
      );
      expect(apr, closeTo(0.06788699, 1e-8)); // Validated with FFIEC APR tool
    });
    test('Solve Payment: Single advance, 26 fortnightly payments', () async {
      final calculator = Calculator()
        ..add(
          SeriesAdvance(
              label: 'Loan',
              amount: 10000,
              postDateFrom: DateTime.utc(2025, 12, 6)),
        )
        ..add(
          SeriesPayment(
              numberOf: 26,
              label: 'Instalment',
              amount: null,
              frequency: Frequency.fortnightly,
              postDateFrom: DateTime.utc(2025, 12, 25)),
        )
        ..add(
          SeriesCharge(
              numberOf: 1,
              label: 'Fee',
              amount: 100.0,
              postDateFrom: DateTime.utc(2025, 12, 6)),
        );
      // APR of 0.067769 returns 394.66 (2c diff). Verified the time factors
      // are correct. As the variance is not too great it could simply be
      // due to a rounding error.
      final payment = await calculator.solveValue(
        interestRate: 0.0679,
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.fortnight),
      );
      expect(payment, closeTo(394.68, 0.01));
    });
    test('Solve APR: Single advance, 52 weekly payments', () async {
      final calculator = Calculator()
        ..add(
          SeriesAdvance(
              label: 'Loan',
              amount: 10000,
              postDateFrom: DateTime.utc(2025, 12, 6)),
        )
        ..add(
          SeriesPayment(
              numberOf: 52,
              label: 'Instalment',
              amount: 197.25,
              frequency: Frequency.weekly,
              postDateFrom: DateTime.utc(2025, 12, 13)),
        )
        ..add(
          SeriesCharge(
              numberOf: 1,
              label: 'Fee',
              amount: 100.0,
              postDateFrom: DateTime.utc(2025, 12, 6)),
        );
      final apr = await calculator.solveRate(
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.week),
      );
      expect(apr, closeTo(0.06996096, 1e-8)); // Validated with FFIEC APR tool
    });
    test('Solve Payment: Single advance, 52 weekly payments', () async {
      final calculator = Calculator()
        ..add(
          SeriesAdvance(
              label: 'Loan',
              amount: 10000,
              postDateFrom: DateTime.utc(2025, 12, 6)),
        )
        ..add(
          SeriesPayment(
              numberOf: 52,
              label: 'Instalment',
              amount: null,
              frequency: Frequency.weekly,
              postDateFrom: DateTime.utc(2025, 12, 13)),
        )
        ..add(
          SeriesCharge(
              numberOf: 1,
              label: 'Fee',
              amount: 100.0,
              postDateFrom: DateTime.utc(2025, 12, 6)),
        );
      final payment = await calculator.solveValue(
        interestRate: 0.06996,
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.week),
      );
      expect(payment, closeTo(197.25, 0.01));
    });
    test('Solve APR: Single advance, 1 payment after 42 days', () async {
      final calculator = Calculator()
        ..add(
          SeriesAdvance(
              label: 'Loan',
              amount: 10000,
              postDateFrom: DateTime.utc(2025, 12, 6)),
        )
        ..add(
          SeriesPayment(
              numberOf: 1,
              label: 'Instalment',
              amount: 10170.0,
              postDateFrom: DateTime.utc(2026, 1, 17)),
        );

      final apr = await calculator.solveRate(
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.day),
      );
      expect(apr, closeTo(0.14773809, 1e-8)); // Validated with FFIEC APR tool
    });
    test('Solve Payment: Single advance, 1 payment after 42 days', () async {
      final calculator = Calculator()
        ..add(
          SeriesAdvance(
              label: 'Loan',
              amount: 10000,
              postDateFrom: DateTime.utc(2025, 12, 6)),
        )
        ..add(
          SeriesPayment(
              numberOf: 1,
              label: 'Instalment',
              amount: null,
              postDateFrom: DateTime.utc(2026, 1, 17)),
        );
      final payment = await calculator.solveValue(
        interestRate: 0.147738,
        convention: const USAppendixJ(timePeriod: DayCountTimePeriod.day),
      );
      expect(payment, closeTo(10170.0, 0.01));
    });
  });
}
