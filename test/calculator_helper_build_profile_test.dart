import 'package:curo/src/calculator.dart';
import 'package:curo/src/calculator_helper.dart';
import 'package:curo/src/enums.dart';
import 'package:curo/src/series.dart';
import 'package:test/test.dart';

// Tests cover buildOrReuseProfile and buildProfile
void main() {
  CashFlowWithFactor cfwf(
    CashFlowType type,
    double amount,
    DateTime postDate,
    DateTime valueDate,
  ) =>
      CashFlowWithFactor(
        cashFlow: (
          type: type,
          postDate: postDate,
          valueDate: valueDate,
          amount: amount,
          isKnown: true,
          weighting: 1.0,
          label: '',
          mode: Mode.arrear,
          isInterestCapitalised: true,
          isCharge: false,
        ),
        factor: const DayCountFactor(primaryPeriodFraction: 0.0),
      );

  final startDate = DateTime.utc(2025, 1, 1);
  final date2 = DateTime.utc(2025, 2, 1);
  final date3 = DateTime.utc(2025, 3, 1);

  group('profile exceptions', () {
    test(
        'throw UnknownCashFlowsWhenSolvingRateException for unknowns when solving rate',
        () {
      final series = <Series>[SeriesAdvance(), SeriesPayment()];
      expect(
        () => buildOrReuseProfile(
            series: series,
            convention: US30360(),
            validationMode: ValidationMode.solveRate,
            existingProfile: null),
        throwsA(isA<UnknownCashFlowsWhenSolvingRateException>()),
      );
    });
    test(
        'throw MissingUnknownCashFlowException for all knowns when solving amount',
        () {
      final series = <Series>[
        SeriesAdvance(amount: 1000),
        SeriesPayment(amount: 1050)
      ];
      expect(
        () => buildOrReuseProfile(
            series: series,
            convention: US30360(),
            validationMode: ValidationMode.solveValue,
            existingProfile: null),
        throwsA(isA<MissingUnknownCashFlowException>()),
      );
    });
    test(
        'throw MixedUnknownCashFlowsException for mixed unknowns when solving amount',
        () {
      final series = <Series>[SeriesAdvance(), SeriesPayment()];
      expect(
        () => buildOrReuseProfile(
            series: series,
            convention: US30360(),
            validationMode: ValidationMode.solveValue,
            existingProfile: null),
        throwsA(isA<MixedUnknownCashFlowsException>()),
      );
    });
    test(
        'throw FinalPaymentInterestNotCapitalisedException for misaligned capital and interest schedules',
        () {
      final series = <Series>[
        SeriesAdvance(amount: 1000, postDateFrom: startDate),
        SeriesPayment(
          // capital repayment series
          numberOf: 6,
          amount: null,
          isInterestCapitalised: false,
          postDateFrom: date3,
        ),
        SeriesPayment(
          // interest only series
          numberOf: 2,
          amount: 0.0,
          frequency: Frequency.quarterly,
          isInterestCapitalised: true,
          postDateFrom: date2, // end dates should align
        ),
      ];
      expect(
        () => buildOrReuseProfile(
            series: series,
            convention: US30360(),
            validationMode: ValidationMode.solveValue,
            existingProfile: null),
        throwsA(isA<FinalPaymentInterestNotCapitalisedException>()),
      );
    });
  });

  test('buildOrReuseProfile reuse to solve rate', () {
    final profile = [
      cfwf(CashFlowType.advance, -1000, startDate, date3),
      cfwf(CashFlowType.payment, 500, date2, date2),
      cfwf(CashFlowType.payment, 500, date3, date3),
    ];
    final profileByPostDate = buildOrReuseProfile(
      series: <Series>[],
      convention: US30360(usePostDates: true),
      validationMode: ValidationMode.solveRate,
      existingProfile: profile,
    );
    expect(profileByPostDate.length, 3);
    expect(profileByPostDate.map((cfwf) => cfwf.cashFlow.amount),
        [-1000.0, 500.0, 500.0]);
    expect(profileByPostDate.map((cfwf) => cfwf.cashFlow.postDate),
        [startDate, date2, date3]);
    expect(profileByPostDate.map((cfwf) => cfwf.cashFlow.valueDate),
        [date3, date2, date3]);
    expect(profileByPostDate.map((cfwf) => cfwf.factor.toString()), [
      'f = 0/360 = 0.00000000',
      'f = 30/360 = 0.08333333',
      'f = 30/360 = 0.08333333',
    ]);

    // Now by valueDate
    final profileByValueDate = buildOrReuseProfile(
      series: <Series>[],
      convention: US30360(usePostDates: false),
      validationMode: ValidationMode.solveRate,
      existingProfile: profileByPostDate,
    );
    expect(profileByValueDate.length, 3);
    expect(profileByValueDate.map((cfwf) => cfwf.cashFlow.amount),
        [500.0, -1000.0, 500.0]);
    expect(profileByValueDate.map((cfwf) => cfwf.cashFlow.postDate),
        [date2, startDate, date3]);
    expect(profileByValueDate.map((cfwf) => cfwf.cashFlow.valueDate),
        [date2, date3, date3]);
    expect(profileByValueDate.map((cfwf) => cfwf.factor.toString()), [
      'f = 0/360 = 0.00000000', // All cashflow value dates <= date3
      'f = 0/360 = 0.00000000',
      'f = 0/360 = 0.00000000',
    ]);
  });

  test('build profile with empty series', () {
    final profile = buildProfile(
      convention: const US30360(), // default usePostDates = false
      series: [],
      startDate: startDate,
    );
    expect(profile, isEmpty);
  });

  test('single dated advance', () {
    final series = [
      SeriesAdvance(
        numberOf: 1,
        amount: 1000.0,
        postDateFrom: startDate,
        label: 'Loan advance',
      ),
    ];

    final profile = buildProfile(
      convention: const US30360(),
      series: series,
      startDate: startDate,
    );

    expect(profile.length, 1);
    final cf = profile[0];
    expect(cf.postDate, startDate);
    expect(cf.valueDate, startDate);
    expect(cf.amount, -1000.0);
    expect(cf.isKnown, true);
    expect(cf.label, 'Loan advance');
    expect(cf.isCharge, false);
    expect(cf.isInterestCapitalised, null);
  });

  test('single undated payment', () {
    final series = [
      SeriesPayment(
        numberOf: 1,
        amount: 1050.0,
        isInterestCapitalised: true,
        label: 'Loan repayment',
      ),
    ];

    final profile = buildProfile(
      convention: const US30360(),
      series: series,
      startDate: startDate,
    );

    expect(profile.length, 1);
    final cf = profile[0];
    expect(cf.postDate, startDate);
    expect(cf.amount, 1050.0);
    expect(cf.isInterestCapitalised, true);
    expect(cf.isCharge, false);
  });

  test('multiple series - advance, payment, charge', () {
    final series = [
      SeriesAdvance(
        amount: 1000.0,
        postDateFrom: startDate,
        label: 'Loan advance',
      ),
      SeriesPayment(
        amount: 1050.0,
        postDateFrom: startDate.add(const Duration(days: 365)),
        label: 'Repayment',
      ),
      SeriesCharge(
        amount: 50.0,
        postDateFrom: startDate,
        label: 'Arrangement fee',
      ),
    ];

    final profile = buildProfile(
      convention: const US30360(usePostDates: true),
      series: series,
      startDate: startDate,
    );

    // Charges are included in the profile by default even when convention.includeNonFinancingFlows: false
    expect(profile.length, 3);
    expect(profile.map((cf) => cf.amount), [
      -1000.0,
      50.0,
      1050.0,
    ]); // sorted by postDate
    expect(profile.map((cf) => cf.isCharge), [false, true, false]);
  });

  test('undated payment Mode.arrear - first at end of period', () {
    final series = [
      SeriesPayment(
        numberOf: 2,
        amount: 500.0,
        frequency: Frequency.monthly,
        mode: Mode.arrear,
        label: 'Repayment',
      ),
    ];

    final profile = buildProfile(
      convention: const US30360(),
      series: series,
      startDate: startDate,
    );

    expect(profile.length, 2);
    expect(profile[0].postDate, date2);
    expect(profile[1].postDate, date3);
  });

  test('undated charge Mode.advance - starts on reference date', () {
    final series = [
      SeriesCharge(numberOf: 1, amount: 50.0, mode: Mode.advance),
      SeriesCharge(
        numberOf: 1,
        amount: 25.0,
        frequency: Frequency.monthly,
        mode: Mode.advance,
      ),
    ];

    final profile = buildProfile(
      convention: const US30360(includeNonFinancingFlows: true),
      series: series,
      startDate: startDate,
    );
    expect(profile[0].postDate, startDate);
    expect(profile[1].postDate, date2);
  });

  test(
      'charges included regardless of convention includeNonFinancingFlows flag',
      () {
    final series = [SeriesCharge(amount: 50.0, postDateFrom: startDate)];

    final profileIncludeFalse = buildProfile(
      convention: const US30360(),
      series: series,
      startDate: startDate,
    );
    expect(profileIncludeFalse, isNotEmpty);
    expect(profileIncludeFalse.length, 1);
    expect(profileIncludeFalse[0].amount, 50.0);

    final profileIncludeTrue = buildProfile(
      convention: const US30360(includeNonFinancingFlows: true),
      series: series,
      startDate: startDate,
    );
    expect(profileIncludeTrue.length, 1);
    expect(profileIncludeTrue[0].amount, 50.0);
  });
}
