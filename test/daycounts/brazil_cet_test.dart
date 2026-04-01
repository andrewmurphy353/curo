import 'package:curo/curo.dart';
import 'package:curo/src/enums.dart';
import 'package:test/test.dart';

void main() {
  group('BrazilCet', () {
    const dc = BrazilCet();

    test('28/01/2020 to 28/02/2020 (leap year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 28),
        DateTime.utc(2020, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(31 / 365, 1e-10));
      expect(factor.toString(), 't = 31/365 = 0.08493151');
      expect(factor.toFoldedString(), 't = 31/365 = 0.08493151');
    });

    test('28/01/2019 to 28/02/2019 (non-leap year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 1, 28),
        DateTime.utc(2019, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(31 / 365, 1e-10));
      expect(factor.toString(), 't = 31/365 = 0.08493151');
      expect(factor.toFoldedString(), 't = 31/365 = 0.08493151');
    });

    test('31/12/2017 to 31/12/2019 (multi-year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2017, 12, 31),
        DateTime.utc(2019, 12, 31),
      );
      expect(factor.primaryPeriodFraction, closeTo(730 / 365, 1e-10));
      expect(factor.toString(), 't = 730/365 = 2.00000000');
      expect(factor.toFoldedString(), 't = 2 = 2.00000000');
    });

    test('30/06/2019 to 30/06/2021 (multi-year with folding)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 6, 30),
        DateTime.utc(2021, 6, 30),
      );
      expect(factor.primaryPeriodFraction, closeTo(731 / 365, 1e-10));
      expect(factor.toString(), 't = 731/365 = 2.00273973');
      expect(factor.toFoldedString(), 't = 2 + 1/365 = 2.00273973');
    });

    test('same day returns zero', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 1),
      );
      expect(factor.primaryPeriodFraction, 0.0);
      expect(factor.toString(), 't = 0/365 = 0.00000000');
      expect(factor.toFoldedString(), 't = 0 = 0.00000000');
    });

    test('end before start throws ArgumentError', () {
      expect(
        () => dc.computeFactor(
          DateTime.utc(2020, 2, 1),
          DateTime.utc(2020, 1, 1),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    group('with useXirrMethod: true', () {
      const cet = BrazilCet();

      test('uses drawdown origin', () {
        expect(cet.usePostDates, isTrue);
        expect(cet.dayCountOrigin, DayCountOrigin.drawdown);
        expect(cet.includeNonFinancingFlows, isTrue);
      });
    });

    group('Brazil CET end-to-end calculations', () {
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
          convention: const BrazilCet(),
        );
        expect(apr, closeTo(0.10520946, 1e-8));
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
        final payment = await calculator.solveValue(
          convention: const BrazilCet(),
          interestRate: 0.10520946,
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
          convention: const BrazilCet(),
        );
        expect(apr, closeTo(0.10828052, 1e-8)); // Validated with FFIEC APR tool
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
          convention: const BrazilCet(),
          interestRate: 0.10828052,
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
          convention: const BrazilCet(),
        );
        expect(apr, closeTo(0.11275793, 1e-8)); // Validated with FFIEC APR tool
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
          convention: const BrazilCet(),
          interestRate: 0.11275793,
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
          convention: const BrazilCet(),
        );
        expect(apr, closeTo(0.1579965, 1e-8)); // Validated with FFIEC APR tool
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
          convention: const BrazilCet(),
          interestRate: 0.1579965,
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
          convention: const BrazilCet(),
        );
        expect(apr, closeTo(0.0702242, 1e-8)); // Validated with FFIEC APR tool
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
        final payment = await calculator.solveValue(
          interestRate: 0.0702242,
          convention: const BrazilCet(),
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
          convention: const BrazilCet(),
        );
        expect(apr, closeTo(0.07262189, 1e-8)); // Validated with FFIEC APR tool
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
          interestRate: 0.07262189,
          convention: const BrazilCet(),
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
          convention: const BrazilCet(),
        );
        expect(apr, closeTo(0.15777073, 1e-8)); // Validated with FFIEC APR tool
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
          interestRate: 0.15777073,
          convention: const BrazilCet(),
        );
        expect(payment, closeTo(10170.0, 0.01));
      });
    });
  });
}
