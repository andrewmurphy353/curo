import 'package:curo/curo.dart';
import 'package:test/test.dart';

void main() {
  group('Amortisation schedule prettyPrint', () {
    test(
        'prettyPrint produces expected borrower amortisation schedule format, by post date',
        () async {
      final calculator = Calculator()
        ..add(SeriesAdvance(label: 'loan', amount: 10000.0))
        ..add(SeriesPayment(
          numberOf: 6,
          label: 'Instalment',
          amount: 1707.00,
          mode: Mode.arrear,
        ));

      final convention = US30U360();

      final irrRate = await calculator.solveRate(
        convention: convention,
        startDate: DateTime.utc(2026, 1, 18),
      ); // Known to be ~ 8.25%

      final schedule = calculator.buildSchedule(
        convention: convention,
        interestRate: irrRate,
      );

      // Expected output as multi-line string
      const expected = '''
post_date    label                            amount        capital       interest  capital_balance
---------------------------------------------------------------------------------------------------
2026-01-18   loan                         -10,000.00     -10,000.00           0.00       -10,000.00
2026-02-18   Instalment                     1,707.00       1,638.25         -68.75        -8,361.75
2026-03-18   Instalment                     1,707.00       1,649.51         -57.49        -6,712.24
2026-04-18   Instalment                     1,707.00       1,660.85         -46.15        -5,051.39
2026-05-18   Instalment                     1,707.00       1,672.27         -34.73        -3,379.12
2026-06-18   Instalment                     1,707.00       1,683.77         -23.23        -1,695.35
2026-07-18   Instalment                     1,707.00       1,695.35         -11.65             0.00
''';
      await expectLater(
          () => schedule.prettyPrint(convention: convention), prints(expected));
    });

    test(
        'prettyPrint produces expected lender amortisation schedule format, by value date',
        () async {
      final calculator = Calculator()
        ..add(SeriesAdvance(
          label: 'loan',
          amount: 10000.0,
          postDateFrom: DateTime.utc(2026, 1, 18),
          valueDateFrom: DateTime.utc(2026, 2, 18),
        ))
        ..add(SeriesPayment(
          numberOf: 6,
          label: 'Instalment',
          amount:
              1695.34, // 1707.00 without deferred settlement - time value of money!
          mode: Mode.arrear,
        ));

      final convention = US30U360(usePostDates: false); // By value date

      final lenderIrr = await calculator.solveRate(
        convention: convention,
        startDate: DateTime.utc(2026, 1, 18),
      ); // Lender IRR ~8.25% (calculated from settlement date), Borrower IRR ~5.87% (calcualted from post date).

      final lenderSchedule = calculator.buildSchedule(
        convention: convention,
        interestRate: lenderIrr,
      );

      // Expected output as multi-line string
      const expected = '''
value_date   label                            amount        capital       interest  capital_balance
---------------------------------------------------------------------------------------------------
2026-02-18   loan                         -10,000.00     -10,000.00           0.00       -10,000.00
2026-02-18   Instalment                     1,695.34       1,695.34           0.00        -8,304.66
2026-03-18   Instalment                     1,695.34       1,638.25         -57.09        -6,666.41
2026-04-18   Instalment                     1,695.34       1,649.52         -45.82        -5,016.89
2026-05-18   Instalment                     1,695.34       1,660.85         -34.49        -3,356.04
2026-06-18   Instalment                     1,695.34       1,672.27         -23.07        -1,683.77
2026-07-18   Instalment                     1,695.34       1,683.77         -11.57             0.00
''';
      await expectLater(
          () => lenderSchedule.prettyPrint(convention: convention),
          prints(expected));
    });
  });

  group('APR Proof schedule prettyPrint', () {
    test('prettyPrint produces expected APR proof format - UKConcApp',
        () async {
      final calculator = Calculator()
        ..add(SeriesAdvance(label: 'Loan', amount: 10000.0))
        ..add(
          SeriesPayment(
            numberOf: 6,
            label: 'Instalment',
            amount: 1707.0,
            mode: Mode.arrear,
          ),
        )
        ..add(SeriesCharge(label: 'Fee', amount: 50.0, mode: Mode.arrear));

      final convention = UKConcApp(isSecuredOnLand: true);

      final aprRate = await calculator.solveRate(
        convention: convention,
        startDate: DateTime.utc(2025, 1, 1),
      ); // Known to be ~10.45% (IRR ~ 8.25%)

      final schedule = calculator.buildSchedule(
        convention: convention,
        interestRate: aprRate,
      );

      // Expected output as multi-line string
      const expected = '''
post_date    label                            amount discount_log                      amount_disc     disc_balance
-------------------------------------------------------------------------------------------------------------------
2025-01-01   Loan                         -10,000.00 t = 0 = 0.00000000                 -10,000.00       -10,000.00
2025-02-01   Instalment                     1,707.00 t = 1/12 = 0.08333333                1,692.92        -8,307.08
2025-02-01   Fee                               50.00 t = 1/12 = 0.08333333                   49.59        -8,257.49
2025-03-01   Instalment                     1,707.00 t = 2/12 = 0.16666667                1,678.96        -6,578.53
2025-04-01   Instalment                     1,707.00 t = 3/12 = 0.25000000                1,665.12        -4,913.41
2025-05-01   Instalment                     1,707.00 t = 4/12 = 0.33333333                1,651.38        -3,262.03
2025-06-01   Instalment                     1,707.00 t = 5/12 = 0.41666667                1,637.77        -1,624.26
2025-07-01   Instalment                     1,707.00 t = 6/12 = 0.50000000                1,624.26             0.00
''';
      await expectLater(
          () => schedule.prettyPrint(convention: convention), prints(expected));
    });

    test('prettyPrint produces expected APR proof format - USAppendixJ',
        () async {
      final calculator = Calculator()
        ..add(SeriesAdvance(label: 'Loan', amount: 10000.0))
        ..add(
          SeriesPayment(
            numberOf: 6,
            label: 'Instalment',
            amount: 1677.79,
            frequency: Frequency.weekly,
            mode: Mode.arrear,
          ),
        )
        ..add(SeriesCharge(
            label: 'Fee',
            amount: 100.0,
            frequency: Frequency.weekly,
            mode: Mode.arrear));

      final convention = USAppendixJ(timePeriod: DayCountTimePeriod.week);

      final aprRate = await calculator.solveRate(
        convention: convention,
        startDate: DateTime.utc(2025, 1, 1),
      ); // Known to be ~24.85% (IRR ~ 10.0%)

      final schedule = calculator.buildSchedule(
        convention: convention,
        interestRate: aprRate,
      );
      // Expected output as multi-line string
      const expected = '''
post_date    label                            amount discount_log                      amount_disc     disc_balance
-------------------------------------------------------------------------------------------------------------------
2025-01-01   Loan                         -10,000.00 t = 0 : f = 0 : p = 52             -10,000.00       -10,000.00
2025-01-08   Instalment                     1,677.79 t = 1 : f = 0 : p = 52               1,669.81        -8,330.19
2025-01-08   Fee                              100.00 t = 1 : f = 0 : p = 52                  99.52        -8,230.67
2025-01-15   Instalment                     1,677.79 t = 2 : f = 0 : p = 52               1,661.87        -6,568.80
2025-01-22   Instalment                     1,677.79 t = 3 : f = 0 : p = 52               1,653.96        -4,914.84
2025-01-29   Instalment                     1,677.79 t = 4 : f = 0 : p = 52               1,646.10        -3,268.74
2025-02-05   Instalment                     1,677.79 t = 5 : f = 0 : p = 52               1,638.27        -1,630.47
2025-02-12   Instalment                     1,677.79 t = 6 : f = 0 : p = 52               1,630.47             0.00
''';
      await expectLater(
          () => schedule.prettyPrint(convention: convention), prints(expected));
    });

    test('prettyPrint handles empty schedule', () {
      final schedule = <ScheduleRow>[];
      expect(() => schedule.prettyPrint(convention: US30U360()),
          prints('Empty schedule\n'));
    });

    test('prettyPrint respects custom date format', () {
      final schedule = [
        (
          type: CashFlowType.advance,
          date: DateTime.utc(2026, 1, 18),
          label: 'loan',
          amount: -10000.0,
          capital: -10000.0,
          interest: 0.0,
          capitalBalance: -10000.0,
          discountLog: null,
          amountDiscounted: null,
          discountedBalance: null,
        ),
      ];
      final convention = US30U360();
      expect(
          () => schedule.prettyPrint(
                convention: convention,
                dateFormat: 'dd/MM/yyyy',
              ),
          prints(
            contains('18/01/2026'),
          ));
      expect(
          () => schedule.prettyPrint(
                convention: convention,
                dateFormat: 'dd/MM/yyyy',
              ),
          prints(
            isNot(
              contains('2026-01-18'),
            ),
          ));
    });
  });
}
