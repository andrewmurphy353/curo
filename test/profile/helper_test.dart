import 'package:curo/curo.dart';
import 'package:curo/src/profile/cash_flow.dart';
import 'package:curo/src/profile/helper.dart';
import 'package:curo/src/series/series.dart';
import 'package:test/test.dart';

class UnsupportedSeries extends Series {
  UnsupportedSeries()
      : super(
          numberOf: 0,
          frequency: Frequency.monthly,
          label: 'Unsupported',
          mode: Mode.advance,
        );
}

void main() {
  group('build', () {
    test('throws exception on receipt of empty list', () {
      expect(
        () => build(series: [], today: DateTime.utc(2022)),
        throwsA(isA<Exception>()),
      );
    });
    test('throws exception for unsupported series type', () {
      expect(
        () => build(series: [UnsupportedSeries()], today: DateTime.utc(2022)),
        throwsA(isA<Exception>()),
      );
    });
    test('advance series undated', () {
      final startDate = DateTime.utc(2022);
      final series = <Series>[
        SeriesAdvance(numberOf: 2),
        SeriesAdvance(mode: Mode.arrear),
      ];
      final cashFlows = build(series: series, today: startDate);
      expect(cashFlows.length, 3);
      expect(cashFlows[0].postDate, DateTime.utc(2022, 1, 1));
      expect(cashFlows[1].postDate, DateTime.utc(2022, 2, 1));
      expect(cashFlows[2].postDate, DateTime.utc(2022, 4, 1));
    });
    test('advance series dated', () {
      final startDate = DateTime.utc(2022);
      final series = <Series>[
        SeriesAdvance(numberOf: 2, postDateFrom: startDate),
        SeriesAdvance(
          mode: Mode.arrear,
          postDateFrom: DateTime.utc(2022, 4, 1),
          valueDateFrom: DateTime.utc(2022, 4, 15),
        ),
      ];
      final cashFlows = build(series: series, today: startDate);
      expect(cashFlows.length, 3);
      expect(cashFlows[0].postDate, DateTime.utc(2022, 1, 1));
      expect(cashFlows[1].postDate, DateTime.utc(2022, 2, 1));
      expect(cashFlows[2].postDate, DateTime.utc(2022, 5, 1));
      expect(cashFlows[2].valueDate, DateTime.utc(2022, 5, 15));
    });
    test('payment series undated', () {
      final startDate = DateTime.utc(2022);
      final series = <Series>[
        SeriesPayment(numberOf: 2),
        SeriesPayment(mode: Mode.arrear),
      ];
      final cashFlows = build(series: series, today: startDate);
      expect(cashFlows.length, 3);
      expect(cashFlows[0].postDate, DateTime.utc(2022, 1, 1));
      expect(cashFlows[1].postDate, DateTime.utc(2022, 2, 1));
      expect(cashFlows[2].postDate, DateTime.utc(2022, 4, 1));
    });
    test('payment series dated', () {
      final startDate = DateTime.utc(2022);
      final series = <Series>[
        SeriesPayment(numberOf: 2, postDateFrom: startDate),
        SeriesPayment(
            mode: Mode.arrear, postDateFrom: DateTime.utc(2022, 4, 1)),
      ];
      final cashFlows = build(series: series, today: startDate);
      expect(cashFlows.length, 3);
      expect(cashFlows[0].postDate, DateTime.utc(2022, 1, 1));
      expect(cashFlows[1].postDate, DateTime.utc(2022, 2, 1));
      expect(cashFlows[2].postDate, DateTime.utc(2022, 5, 1));
    });
    test('charge series undated', () {
      final startDate = DateTime.utc(2022);
      final series = <Series>[
        SeriesCharge(numberOf: 2, value: 10.0),
        SeriesCharge(value: 10.0, mode: Mode.arrear),
      ];
      final cashFlows = build(series: series, today: startDate);
      expect(cashFlows.length, 3);
      expect(cashFlows[0].postDate, DateTime.utc(2022, 1, 1));
      expect(cashFlows[1].postDate, DateTime.utc(2022, 2, 1));
      expect(cashFlows[2].postDate, DateTime.utc(2022, 4, 1));
    });
    test('charge series dated', () {
      final startDate = DateTime.utc(2022);
      final series = <Series>[
        SeriesCharge(numberOf: 2, value: 10.0, postDateFrom: startDate),
        SeriesCharge(
            value: 10.0,
            mode: Mode.arrear,
            postDateFrom: DateTime.utc(2022, 4, 1)),
      ];
      final cashFlows = build(series: series, today: startDate);
      expect(cashFlows.length, 3);
      expect(cashFlows[0].postDate, DateTime.utc(2022, 1, 1));
      expect(cashFlows[1].postDate, DateTime.utc(2022, 2, 1));
      expect(cashFlows[2].postDate, DateTime.utc(2022, 5, 1));
    });
  }, skip: false);
  group('assignFactors', () {
    group(
        'using US30360 and post dates, exclude charge '
        'cash flow factors', () {
      var profile = Profile(
        cashFlows: <CashFlow>[
          CashFlowAdvance(
            postDate: DateTime.utc(2022, 1, 1),
            value: -600.0,
          ),
          CashFlowAdvance(
            postDate: DateTime.utc(2022, 1, 1),
            valueDate: DateTime.utc(2022, 1, 16),
            value: -400.0,
          ),
          CashFlowCharge(postDate: DateTime.utc(2022, 1, 1), value: 10.0),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 2, 1),
            value: 100.0,
          ),
          CashFlowCharge(
            postDate: DateTime.utc(2022, 2, 16),
            value: 20.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 300.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 400.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 200.0,
            isInterestCapitalised: false,
          ),
        ],
        dayCount: const US30360(),
      );
      profile = assignFactors(profile);

      test('- drawdown post date equal to 01/01/2022', () {
        expect(profile.firstDrawdownPostDate, DateTime.utc(2022, 1, 1));
      });
      test('- drawdown value date equal to 01/01/2022', () {
        expect(profile.firstDrawdownValueDate, DateTime.utc(2022, 1, 1));
      });
      test('- cashFlow[0]: 600.0 advance, factor of 0.0', () {
        expect(profile.cashFlows[0].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[0].valueDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[0].value, -600.0);
        expect(profile.cashFlows[0].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[1]: 400.0 advance, factor of 0.0', () {
        expect(profile.cashFlows[1].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[1].valueDate, DateTime.utc(2022, 1, 16));
        expect(profile.cashFlows[1].value, -400.0);
        expect(profile.cashFlows[1].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[2] 10.0 charge, factor of 0.0 (excluded)', () {
        expect(profile.cashFlows[2].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[2].valueDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[2].value, 10.0);
        expect(profile.cashFlows[2].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[3] 100.0 payment, factor of 0.08333333333333333', () {
        expect(profile.cashFlows[3].postDate, DateTime.utc(2022, 2, 1));
        expect(profile.cashFlows[3].valueDate, DateTime.utc(2022, 2, 1));
        expect(profile.cashFlows[3].value, 100.0);
        expect(profile.cashFlows[3].periodFactor!.factor, 0.08333333333333333);
      });
      test('- cashFlow[4] 20.0 charge, factor of 0.0 (excluded)', () {
        expect(profile.cashFlows[4].postDate, DateTime.utc(2022, 2, 16));
        expect(profile.cashFlows[4].valueDate, DateTime.utc(2022, 2, 16));
        expect(profile.cashFlows[4].value, 20.0);
        expect(profile.cashFlows[4].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[5] 200.0 payment, factor of 0.08333333333333333', () {
        expect(profile.cashFlows[5].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[5].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[5].value, 200.0);
        expect(profile.cashFlows[5].periodFactor!.factor, 0.08333333333333333);
      });
      test('- cashFlow[6] 300.0 payment, factor of 0.0', () {
        expect(profile.cashFlows[6].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[6].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[6].value, 300.0);
        expect(profile.cashFlows[6].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[7] 400.0 payment, factor of 0.0', () {
        expect(profile.cashFlows[7].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[7].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[7].value, 400.0);
        expect(profile.cashFlows[7].periodFactor!.factor, 0.0);
      });
    }, skip: false);
    group(
        'using US30360 and post dates, include charge '
        'cash flow factors', () {
      var profile = Profile(
        cashFlows: <CashFlow>[
          CashFlowAdvance(
            postDate: DateTime.utc(2022, 1, 1),
            value: -600.0,
          ),
          CashFlowAdvance(
            postDate: DateTime.utc(2022, 1, 1),
            valueDate: DateTime.utc(2022, 1, 16),
            value: -400.0,
          ),
          CashFlowCharge(postDate: DateTime.utc(2022, 1, 1), value: 10.0),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 2, 1),
            value: 100.0,
          ),
          CashFlowCharge(postDate: DateTime.utc(2022, 2, 16), value: 20.0),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 200.0,
            isInterestCapitalised: false,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 300.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 400.0,
          ),
        ],
        dayCount: const US30360(includeNonFinancingFlows: true),
      );
      profile = assignFactors(profile);

      test('- cashFlow[0]: -600.0 advance, factor of 0.0', () {
        expect(profile.cashFlows[0].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[0].valueDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[0].value, -600.0);
        expect(profile.cashFlows[0].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[1]: -400.0 advance, factor of 0.0', () {
        expect(profile.cashFlows[1].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[1].valueDate, DateTime.utc(2022, 1, 16));
        expect(profile.cashFlows[1].value, -400.0);
        expect(profile.cashFlows[1].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[2] 10.0 charge, factor of 0.0 (included)', () {
        expect(profile.cashFlows[2].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[2].valueDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[2].value, 10.0);
        expect(profile.cashFlows[2].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[3] 100.0 payment, factor of 0.08333333333333333', () {
        expect(profile.cashFlows[3].postDate, DateTime.utc(2022, 2, 1));
        expect(profile.cashFlows[3].valueDate, DateTime.utc(2022, 2, 1));
        expect(profile.cashFlows[3].value, 100.0);
        expect(profile.cashFlows[3].periodFactor!.factor, 0.08333333333333333);
      });
      test(
          '- cashFlow[4] 20.0 charge, factor of 0.041666666666666664 '
          '(included)', () {
        expect(profile.cashFlows[4].postDate, DateTime.utc(2022, 2, 16));
        expect(profile.cashFlows[4].valueDate, DateTime.utc(2022, 2, 16));
        expect(profile.cashFlows[4].value, 20.0);
        expect(profile.cashFlows[4].periodFactor!.factor, 0.041666666666666664);
      });
      test('- cashFlow[5] 200.0 payment, factor of 0.041666666666666664', () {
        expect(profile.cashFlows[5].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[5].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[5].value, 200.0);
        expect(profile.cashFlows[5].periodFactor!.factor, 0.041666666666666664);
      });
      test('- cashFlow[6] 300.0 payment, factor of 0.0', () {
        expect(profile.cashFlows[6].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[6].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[6].value, 300.0);
        expect(profile.cashFlows[6].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[7] 400.0 payment, factor of 0.0', () {
        expect(profile.cashFlows[7].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[7].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[7].value, 400.0);
        expect(profile.cashFlows[7].periodFactor!.factor, 0.0);
      });
    });
    group(
        'using US30360 and post dates relative to first drawdown, '
        'include charge cash flow factors', () {
      var profile = Profile(
        cashFlows: <CashFlow>[
          CashFlowAdvance(
            postDate: DateTime.utc(2022, 1, 1),
            value: -600.0,
          ),
          CashFlowAdvance(
            postDate: DateTime.utc(2022, 1, 1),
            valueDate: DateTime.utc(2022, 1, 16),
            value: -400.0,
          ),
          CashFlowCharge(
            postDate: DateTime.utc(2022, 1, 1),
            value: 10.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 2, 1),
            value: 100.0,
          ),
          CashFlowCharge(
            postDate: DateTime.utc(2022, 2, 16),
            value: 20.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 200.0,
            isInterestCapitalised: false,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 300.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 400.0,
          ),
        ],
        dayCount: const US30360(
          includeNonFinancingFlows: true,
          useXirrMethod: true,
        ),
      );
      profile = assignFactors(profile);

      test('- cashFlow[0]: 600.0 advance, factor of 0.0', () {
        expect(profile.cashFlows[0].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[0].valueDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[0].value, -600.0);
        expect(profile.cashFlows[0].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[1]: 400.0 advance, factor of 0.0', () {
        expect(profile.cashFlows[1].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[1].valueDate, DateTime.utc(2022, 1, 16));
        expect(profile.cashFlows[1].value, -400.0);
        expect(profile.cashFlows[1].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[2] 10.0 charge, factor of 0.0 (included)', () {
        expect(profile.cashFlows[2].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[2].valueDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[2].value, 10.0);
        expect(profile.cashFlows[2].periodFactor!.factor, 0.0);
      });
      test('cashFlow[3] 100.0 payment, factor of 0.08333333333333333', () {
        expect(profile.cashFlows[3].postDate, DateTime.utc(2022, 2, 1));
        expect(profile.cashFlows[3].valueDate, DateTime.utc(2022, 2, 1));
        expect(profile.cashFlows[3].value, 100.0);
        expect((profile.cashFlows[3] as CashFlowPayment).isInterestCapitalised,
            true);
        expect(profile.cashFlows[3].periodFactor!.factor, 0.08333333333333333);
      });
      test('cashFlow[4] 20.0 charge, factor of 0.125 (included)', () {
        expect(profile.cashFlows[4].postDate, DateTime.utc(2022, 2, 16));
        expect(profile.cashFlows[4].valueDate, DateTime.utc(2022, 2, 16));
        expect(profile.cashFlows[4].value, 20.0);
        expect(profile.cashFlows[4].periodFactor!.factor, 0.125);
      });
      test('cashFlow[5] 200.0 payment, factor of 0.16666666666666666', () {
        expect(profile.cashFlows[5].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[5].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[5].value, 200.0);
        expect(profile.cashFlows[5].periodFactor!.factor, 0.16666666666666666);
      });
      test('cashFlow[6] 300.0 payment, factor of 0.16666666666666666', () {
        expect(profile.cashFlows[6].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[6].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[6].value, 300.0);
        expect(profile.cashFlows[6].periodFactor!.factor, 0.16666666666666666);
      });
      test('cashFlow[7] 400.0 payment, factor of 0.16666666666666666', () {
        expect(profile.cashFlows[7].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[7].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[7].value, 400.0);
        expect(profile.cashFlows[7].periodFactor!.factor, 0.16666666666666666);
      });
    });
    group(
        'using US30360 and value dates, exclude charge '
        'cash flow factors', () {
      var profile = Profile(
        cashFlows: <CashFlow>[
          CashFlowAdvance(
            postDate: DateTime.utc(2022, 1, 1),
            value: -600.0,
          ),
          CashFlowCharge(postDate: DateTime.utc(2022, 1, 1), value: 10.0),
          CashFlowAdvance(
            postDate: DateTime.utc(2022, 1, 1),
            valueDate: DateTime.utc(2022, 1, 16),
            value: -400.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 2, 1),
            value: 100.0,
          ),
          CashFlowCharge(postDate: DateTime.utc(2022, 2, 16), value: 20.0),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 200.0,
            isInterestCapitalised: false,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 300.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 400.0,
          ),
        ],
        dayCount: const US30360(usePostDates: false),
      );
      profile = assignFactors(profile);

      test('- cashFlow[0]: 600.0 advance, factor of 0.0', () {
        expect(profile.cashFlows[0].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[0].valueDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[0].value, -600.0);
        expect(profile.cashFlows[0].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[1] 10.0 charge, factor of 0.0 (excluded)', () {
        expect(profile.cashFlows[1].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[1].valueDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[1].value, 10.0);
        expect(profile.cashFlows[1].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[2]: 400.0 advance, factor of 0.041666666666666664', () {
        expect(profile.cashFlows[2].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[2].valueDate, DateTime.utc(2022, 1, 16));
        expect(profile.cashFlows[2].value, -400.0);
        expect(profile.cashFlows[2].periodFactor!.factor, 0.041666666666666664);
      });
      test('- cashFlow[3] 100.0 payment, factor of 0.041666666666666664', () {
        expect(profile.cashFlows[3].postDate, DateTime.utc(2022, 2, 1));
        expect(profile.cashFlows[3].valueDate, DateTime.utc(2022, 2, 1));
        expect(profile.cashFlows[3].value, 100.0);
        expect((profile.cashFlows[3] as CashFlowPayment).isInterestCapitalised,
            true);
        expect(profile.cashFlows[3].periodFactor!.factor, 0.041666666666666664);
      });
      test('- cashFlow[4] 20.0 charge, factor of 0.0 (excluded)', () {
        expect(profile.cashFlows[4].postDate, DateTime.utc(2022, 2, 16));
        expect(profile.cashFlows[4].valueDate, DateTime.utc(2022, 2, 16));
        expect(profile.cashFlows[4].value, 20.0);
        expect(profile.cashFlows[4].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[5] 200.0 payment, factor of 0.08333333333333333', () {
        expect(profile.cashFlows[5].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[5].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[5].value, 200.0);
        expect(profile.cashFlows[5].periodFactor!.factor, 0.08333333333333333);
      });
      test('- cashFlow[6] 300.0 payment, factor of 0.0', () {
        expect(profile.cashFlows[6].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[6].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[6].value, 300.0);
        expect(profile.cashFlows[6].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[7] 400.0 payment, factor of 0.0', () {
        expect(profile.cashFlows[7].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[7].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[7].value, 400.0);
        expect(profile.cashFlows[7].periodFactor!.factor, 0.0);
      });
    });
    group(
        'using US30360 and value dates, include charge '
        'cash flow factors', () {
      var profile = Profile(
        cashFlows: <CashFlow>[
          CashFlowAdvance(
            postDate: DateTime.utc(2022, 1, 1),
            value: -600.0,
          ),
          CashFlowCharge(postDate: DateTime.utc(2022, 1, 1), value: 10.0),
          CashFlowAdvance(
            postDate: DateTime.utc(2022, 1, 1),
            valueDate: DateTime.utc(2022, 1, 16),
            value: -400.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 2, 1),
            value: 100.0,
          ),
          CashFlowCharge(postDate: DateTime.utc(2022, 2, 16), value: 20.0),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 200.0,
            isInterestCapitalised: false,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 300.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 400.0,
          ),
        ],
        dayCount: const US30360(
          usePostDates: false,
          includeNonFinancingFlows: true,
        ),
      );
      profile = assignFactors(profile);

      test('- cashFlow[0]: 600.0 advance, factor of 0.0', () {
        expect(profile.cashFlows[0].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[0].valueDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[0].value, -600.0);
        expect(profile.cashFlows[0].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[1] 10.0 charge, factor of 0.0 (included)', () {
        expect(profile.cashFlows[1].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[1].valueDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[1].value, 10.0);
        expect(profile.cashFlows[1].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[2]: 400.0 advance, factor of 0.041666666666666664', () {
        expect(profile.cashFlows[2].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[2].valueDate, DateTime.utc(2022, 1, 16));
        expect(profile.cashFlows[2].value, -400.0);
        expect(profile.cashFlows[2].periodFactor!.factor, 0.041666666666666664);
      });
      test('- cashFlow[3] 100.0 payment, factor of 0.041666666666666664', () {
        expect(profile.cashFlows[3].postDate, DateTime.utc(2022, 2, 1));
        expect(profile.cashFlows[3].valueDate, DateTime.utc(2022, 2, 1));
        expect(profile.cashFlows[3].value, 100.0);
        expect(profile.cashFlows[3].periodFactor!.factor, 0.041666666666666664);
      });
      test(
          '- cashFlow[4] 20.0 charge, factor of 0.041666666666666664 '
          '(included)', () {
        expect(profile.cashFlows[4].postDate, DateTime.utc(2022, 2, 16));
        expect(profile.cashFlows[4].valueDate, DateTime.utc(2022, 2, 16));
        expect(profile.cashFlows[4].value, 20.0);
        expect(profile.cashFlows[4].periodFactor!.factor, 0.041666666666666664);
      });
      test('- cashFlow[5] 200.0 payment, factor of 0.041666666666666664', () {
        expect(profile.cashFlows[5].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[5].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[5].value, 200.0);
        expect(profile.cashFlows[5].periodFactor!.factor, 0.041666666666666664);
      });
      test('- cashFlow[6] 300.0 payment, factor of 0.0', () {
        expect(profile.cashFlows[6].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[6].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[6].value, 300.0);
        expect(profile.cashFlows[6].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[7] 400.0 payment, factor of 0.0', () {
        expect(profile.cashFlows[7].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[7].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[7].value, 400.0);
        expect(profile.cashFlows[7].periodFactor!.factor, 0.0);
      });
    });
    group(
        'using US30360 with value dates relative to first drawdown, '
        'exclude charge cash flow factors', () {
      var profile = Profile(
        cashFlows: <CashFlow>[
          CashFlowAdvance(
            postDate: DateTime.utc(2022, 1, 1),
            value: -600.0,
          ),
          CashFlowCharge(postDate: DateTime.utc(2022, 1, 1), value: 10.0),
          CashFlowAdvance(
            postDate: DateTime.utc(2022, 1, 1),
            valueDate: DateTime.utc(2022, 1, 16),
            value: -400.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 2, 1),
            value: 100.0,
          ),
          CashFlowCharge(postDate: DateTime.utc(2022, 2, 16), value: 20.0),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 300.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 400.0,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 200.0,
            isInterestCapitalised: false,
          ),
          //
        ],
        dayCount: const US30360(
          usePostDates: false,
          includeNonFinancingFlows: false,
          useXirrMethod: true,
        ),
      );
      profile = assignFactors(profile);

      test('- cashFlow[0]: 600.0 advance, factor of 0.0', () {
        expect(profile.cashFlows[0].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[0].valueDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[0].value, -600.0);
        expect(profile.cashFlows[0].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[1] 10.0 charge, factor of 0.0 (excluded)', () {
        expect(profile.cashFlows[1].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[1].valueDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[1].value, 10.0);
        expect(profile.cashFlows[1].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[2]: 400.0 advance, factor of 0.041666666666666664', () {
        expect(profile.cashFlows[2].postDate, DateTime.utc(2022, 1, 1));
        expect(profile.cashFlows[2].valueDate, DateTime.utc(2022, 1, 16));
        expect(profile.cashFlows[2].value, -400.0);
        expect(profile.cashFlows[2].periodFactor!.factor, 0.041666666666666664);
      });
      test('- cashFlow[3] 100.0 payment, factor of 0.08333333333333333', () {
        expect(profile.cashFlows[3].postDate, DateTime.utc(2022, 2, 1));
        expect(profile.cashFlows[3].valueDate, DateTime.utc(2022, 2, 1));
        expect(profile.cashFlows[3].value, 100.0);
        expect((profile.cashFlows[3] as CashFlowPayment).isInterestCapitalised,
            true);
        expect(profile.cashFlows[3].periodFactor!.factor, 0.08333333333333333);
      });
      test('- cashFlow[4] 20.0 charge, factor of 0.0 (excluded)', () {
        expect(profile.cashFlows[4].postDate, DateTime.utc(2022, 2, 16));
        expect(profile.cashFlows[4].valueDate, DateTime.utc(2022, 2, 16));
        expect(profile.cashFlows[4].value, 20.0);
        expect(profile.cashFlows[4].periodFactor!.factor, 0.0);
      });
      test('- cashFlow[5] 200.0 payment, factor of 0.16666666666666666', () {
        expect(profile.cashFlows[5].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[5].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[5].value, 200.0);
        expect(profile.cashFlows[5].periodFactor!.factor, 0.16666666666666666);
      });
      test('- cashFlow[6] 300.0 payment, factor of 0.16666666666666666', () {
        expect(profile.cashFlows[6].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[6].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[6].value, 300.0);
        expect(profile.cashFlows[6].periodFactor!.factor, 0.16666666666666666);
      });
      test('- cashFlow[7] 400.0 payment, factor of 0.16666666666666666', () {
        expect(profile.cashFlows[7].postDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[7].valueDate, DateTime.utc(2022, 3, 1));
        expect(profile.cashFlows[7].value, 400.0);
        expect(profile.cashFlows[7].periodFactor!.factor, 0.16666666666666666);
      });
    });
  }, skip: false);
  group('sort', () {
    test('unordered cash flows by post dates', () {
      final cfa1 = CashFlowAdvance(postDate: DateTime.utc(2022, 1, 1));
      final cfa2 = CashFlowAdvance(
        postDate: DateTime.utc(2022, 1, 1),
        valueDate: DateTime.utc(2022, 1, 15),
      );
      final cfp1 = CashFlowPayment(postDate: DateTime.utc(2022, 1, 1));
      final cfp2 = CashFlowPayment(postDate: DateTime.utc(2022, 2, 1));
      final cfp3 = CashFlowPayment(postDate: DateTime.utc(2022, 3, 1));
      final cfp4 = CashFlowPayment(
          postDate: DateTime.utc(2022, 3, 1), isInterestCapitalised: false);
      final cfc1 =
          CashFlowCharge(postDate: DateTime.utc(2022, 1, 1), value: 0.0);
      // add unsorted
      var cashFlows = <CashFlow>[cfp2, cfp4, cfp1, cfa2, cfa1, cfp3, cfc1];
      cashFlows = sort(cashFlows, const US30360());
      expect(cashFlows[0], cfa1);
      expect(cashFlows[1], cfa2);
      expect(cashFlows[2], cfc1);
      expect(cashFlows[3], cfp1);
      expect(cashFlows[4], cfp2);
      expect(cashFlows[5], cfp4);
      expect(cashFlows[6], cfp3);
    });
    test('unordered cash flows by value dates', () {
      final cfa1 = CashFlowAdvance(postDate: DateTime.utc(2022, 1, 1));
      final cfa2 = CashFlowAdvance(
        postDate: DateTime.utc(2022, 1, 1),
        valueDate: DateTime.utc(2022, 1, 15),
      );
      final cfp1 = CashFlowPayment(postDate: DateTime.utc(2022, 1, 1));
      final cfp2 = CashFlowPayment(postDate: DateTime.utc(2022, 2, 1));
      final cfp3 = CashFlowPayment(postDate: DateTime.utc(2022, 3, 1));
      final cfp4 = CashFlowPayment(
          postDate: DateTime.utc(2022, 3, 1), isInterestCapitalised: false);
      final cfc1 =
          CashFlowCharge(postDate: DateTime.utc(2022, 1, 1), value: 0.0);
      // add unsorted
      var cashFlows = <CashFlow>[cfp2, cfp4, cfp1, cfa2, cfa1, cfp3, cfc1];
      cashFlows = sort(cashFlows, const US30360(usePostDates: false));
      expect(cashFlows[0], cfa1);
      expect(cashFlows[1], cfc1);
      expect(cashFlows[2], cfp1);
      expect(cashFlows[3], cfa2);
      expect(cashFlows[4], cfp2);
      expect(cashFlows[5], cfp4);
      expect(cashFlows[6], cfp3);
    });
  }, skip: false);
  group('computeFactors', () {
    test('based on neighbour post dates, excluding charges', () {
      final drawDownDate = DateTime.utc(2022, 1, 1);
      var cashFlows = <CashFlow>[
        CashFlowPayment(postDate: DateTime.utc(2021, 12, 15)),
        CashFlowAdvance(postDate: drawDownDate),
        CashFlowCharge(postDate: DateTime.utc(2022, 1, 15), value: 10.0),
        CashFlowPayment(postDate: DateTime.utc(2022, 2, 1)),
      ];
      cashFlows = computeFactors(cashFlows, const US30360(), drawDownDate);

      // Predates drawdown
      expect(cashFlows[0].periodFactor!.factor, 0.0);
      // Advance is drawn down
      expect(cashFlows[1].periodFactor!.factor, 0.0);
      // Charge is excluded from computation
      expect(cashFlows[2].periodFactor!.factor, 0.0);
      // Payment falls due 30 days (30/360) after drawdown
      expect(cashFlows[3].periodFactor!.factor, 0.08333333333333333);
    });
    test('based on neighbour value dates, including charges', () {
      final drawDownDate = DateTime.utc(2022, 1, 15);
      var cashFlows = <CashFlow>[
        CashFlowPayment(postDate: DateTime.utc(2022, 1, 1)),
        CashFlowAdvance(
          postDate: DateTime.utc(2022),
          valueDate: drawDownDate,
        ),
        CashFlowCharge(postDate: DateTime.utc(2022, 1, 31), value: 10.0),
        CashFlowPayment(postDate: DateTime.utc(2022, 2, 15)),
      ];
      cashFlows = computeFactors(
        cashFlows,
        const US30360(usePostDates: false, includeNonFinancingFlows: true),
        drawDownDate,
      );

      // Predates drawdown
      expect(cashFlows[0].periodFactor!.factor, 0.0);
      // Advance is drawn down
      expect(cashFlows[1].periodFactor!.factor, 0.0);
      // Charge falls due 16 days after drawdown (16/360)
      expect(cashFlows[2].periodFactor!.factor, 0.044444444444444446);
      // Payment falls due 15 days after charge (15/360)
      expect(cashFlows[3].periodFactor!.factor, 0.041666666666666664);
    });
    test('based on drawdown value dates, including charges', () {
      final drawDownDate = DateTime.utc(2022, 1, 15);
      var cashFlows = <CashFlow>[
        CashFlowPayment(postDate: DateTime.utc(2022, 1, 1)),
        CashFlowAdvance(
          postDate: DateTime.utc(2022),
          valueDate: drawDownDate,
        ),
        CashFlowCharge(postDate: DateTime.utc(2022, 1, 31), value: 10.0),
        CashFlowPayment(postDate: DateTime.utc(2022, 2, 15)),
      ];
      cashFlows = computeFactors(
        cashFlows,
        const US30360(
          usePostDates: false,
          includeNonFinancingFlows: true,
          useXirrMethod: true,
        ),
        drawDownDate,
      );

      // Predates drawdown
      expect(cashFlows[0].periodFactor!.factor, 0.0);
      // Advance is drawn down
      expect(cashFlows[1].periodFactor!.factor, 0.0);
      // Charge falls due 16 days after drawdown (16/360)
      expect(cashFlows[2].periodFactor!.factor, 0.044444444444444446);
      // Payment falls due 30 days after drawdown (30/360)
      expect(cashFlows[3].periodFactor!.factor, 0.083333333333333333);
    });
  }, skip: false);
  group('updateUnknowns', () {
    group('no rounding', () {
      final today = DateTime.utc(2022);
      var cashFlows = <CashFlow>[
        CashFlowAdvance(postDate: today, value: -1000.0),
        CashFlowPayment(postDate: today, isKnown: false),
        CashFlowPayment(postDate: today, isKnown: false)
      ];
      cashFlows = updateUnknowns(
        cashFlows: cashFlows,
        value: 500.006,
        precision: 2,
      );
      test('cashFlow[0]: -1000.00 advance (not updated)', () {
        expect(cashFlows[0].value, -1000.0);
      });
      test('cashFlow[1]: 500.006 payment', () {
        expect(cashFlows[1].value, 500.006);
      });
      test('cashFlow[2]: 500.006 payment', () {
        expect(cashFlows[2].value, 500.006);
      });
    });
    group('rounding to 2 decimal places', () {
      final today = DateTime.utc(2022);
      var cashFlows = <CashFlow>[
        CashFlowAdvance(postDate: today, value: -1000.0),
        CashFlowPayment(postDate: today, isKnown: false),
        CashFlowPayment(postDate: today, isKnown: false)
      ];
      cashFlows = updateUnknowns(
        cashFlows: cashFlows,
        value: 500.006,
        precision: 2,
        isRounded: true,
      );
      test('cashFlow[0]: -1000.00 advance (not updated)', () {
        expect(cashFlows[0].value, -1000.0);
      });
      test('cashFlow[1]: 500.01 payment', () {
        expect(cashFlows[1].value, 500.01);
      });
      test('cashFlow[2]: 500.01 payment', () {
        expect(cashFlows[2].value, 500.01);
      });
    });
  }, skip: false);
  group('amortiseInterest', () {
    var profile = Profile(cashFlows: [
      CashFlowAdvance(
        postDate: DateTime.utc(2019, 0, 1),
        value: -1000.0,
      ), // skipped
      CashFlowCharge(
        postDate: DateTime.utc(2019, 0, 1),
        value: 10.0,
      ), // skipped
      CashFlowPayment(
        postDate: DateTime.utc(2019, 1, 1),
        value: 340.02,
        isInterestCapitalised: false,
      ),
      CashFlowPayment(
        postDate: DateTime.utc(2019, 2, 1),
        value: 340.02,
        isInterestCapitalised: false,
      ),
      CashFlowPayment(
        postDate: DateTime.utc(2019, 3, 1),
        value: 340.02,
      )
    ]);
    profile = assignFactors(profile);
    final cashFlows = amortiseInterest(profile.cashFlows, 0.12, 2);
    test('cashFlow[2]: 0.0 interest', () {
      expect((cashFlows[2] as CashFlowPayment).interest, 0.0);
    });
    test('cashFlow[3]: 0.0 interest', () {
      expect((cashFlows[3] as CashFlowPayment).interest, 0.0);
    });
    test('cashFlow[4]: -20.06 interest', () {
      expect((cashFlows[4] as CashFlowPayment).interest, -20.06);
    });
  }, skip: false);
  group('weightAdjustedValue', () {
    test(
        'computes the unrounded value of the cash flow, '
        'taking account of the weighting', () {
      expect(
        2666.6706,
        weightAdjustedValue(
          value: 1333.3353,
          weighting: 2.0,
        ),
      );
    });
    test(
        'computes the rounded value of the cash flow, '
        'taking account of the weighting', () {
      expect(
        2666.67,
        weightAdjustedValue(
          value: 1333.3353,
          weighting: 2.0,
          precision: 2,
        ),
      );
    });
  });
}
