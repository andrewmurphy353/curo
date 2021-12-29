import 'package:curo/curo.dart';
import 'package:curo/src/core/calculator.dart';
import 'package:curo/src/daycount/act_365.dart';
import 'package:curo/src/daycount/eu_2008_48_ec.dart';
import 'package:curo/src/profile/cash_flow.dart';
import 'package:curo/src/profile/cash_flow_advance.dart';
import 'package:curo/src/profile/cash_flow_payment.dart';
import 'package:curo/src/profile/profile.dart';
import 'package:curo/src/series/mode.dart';
import 'package:curo/src/series/series_advance.dart';
import 'package:curo/src/series/series_charge.dart';
import 'package:curo/src/series/series_payment.dart';
import 'package:test/test.dart';

void main() {
  group('Calculator constructor', () {
    test('Default no params should set precision to 2', () {
      final calc = Calculator();
      expect(calc.precision, 2);
    });
    test(
        'with bespoke profile and precision of 4 should '
        'should override calculator provided precision', () {
      final cashFlows = <CashFlow>[];
      cashFlows.add(CashFlowAdvance(
        postDate: DateTime.utc(2022),
      ));
      cashFlows.add(
        CashFlowPayment(
          postDate: DateTime.utc(2022),
          value: 100.0,
          isKnown: true,
        ),
      );
      final calc = Calculator(
        precision: 3, // will be overridden by profile
        profile: Profile(cashFlows: cashFlows, precision: 4),
      );
      expect(calc.precision, 4);
    });
    test('throws an exception for unsupported precision of 1', () {
      expect(
        () => Calculator(precision: 1),
        throwsA(isA<Exception>()),
      );
    });
  });
  group('Calculator get profile', () {
    test('throws an exception when called before initialisation', () {
      expect(
        () => Calculator()..profile,
        throwsA(isA<Exception>()),
      );
    });
  });
  group('Calculator add(Series series)', () {
    test('throws an exception when a series is added to a bespoke profile', () {
      final calc = Calculator(
        profile: Profile(
          cashFlows: [
            CashFlowAdvance(postDate: DateTime.utc(2022)),
            CashFlowPayment(
              postDate: DateTime.utc(2022),
              value: 100.0,
              isKnown: true,
            ),
          ],
        ),
      );
      expect(
        () => calc.add(SeriesPayment()),
        throwsA(isA<Exception>()),
      );
    });
    test('coerces the series value to the expected precision', () {
      final calc = Calculator();
      calc.add(SeriesAdvance(value: 999.989));
      calc.add(SeriesPayment(numberOf: 3, value: 123.4467));
      calc.add(SeriesCharge(value: 32.442));
      expect(calc.series[0].value, 999.99);
      expect(calc.series[1].value, 123.45);
      expect(calc.series[2].value, 32.44);
    });
  });
  group('Calculator solveValue', () {
    test(
        'solve for loan of 1000.0, 12.0% IRR, 3 monthly repayments '
        'in arrears mode using US30360', () {
      final calculator = Calculator()
        ..add(SeriesAdvance(value: 1000.0))
        ..add(SeriesPayment(numberOf: 3, mode: Mode.arrear));
      expect(
        calculator.solveValue(
          dayCount: const US30360(),
          interestRate: 0.12,
        ),
        340.02,
      );
    });
    test(
        'solve for loan of 1000.0, 12.0% XIRR, 3 monthly repayments '
        'in arrears mode using US30360', () {
      final calculator = Calculator()
        ..add(SeriesAdvance(value: 1000.0))
        ..add(SeriesPayment(numberOf: 3, mode: Mode.arrear));
      expect(
        calculator.solveValue(
          dayCount: const US30360(useXirrMethod: true),
          interestRate: 0.12,
        ),
        339.68,
      );
    });
  });
  group('Calculator solveRate', () {
    test(
        'solve US30360 IRR for loan of 1000.0, 3 monthly repayments '
        'of 340.02 in arrears mode', () {
      final calculator = Calculator()
        ..add(SeriesAdvance(value: 1000.0))
        ..add(SeriesPayment(numberOf: 3, value: 340.02, mode: Mode.arrear));
      expect(
        calculator.solveRate(dayCount: const US30360()),
        0.11996224312757968,
      );
    });
    test(
        'solve EU200848EC APR for loan of 1000.0, 6 monthly repayments '
        'of 172.55 in arrears mode', () {
      final calculator = Calculator()
        ..add(SeriesAdvance(value: 1000.0))
        ..add(SeriesPayment(numberOf: 6, value: 172.55, mode: Mode.arrear));
      expect(
        calculator.solveRate(dayCount: const EU200848EC()),
        0.12686190609643871,
      );
    });
    test(
        'solve US30360 XIRR for loan of 1000.0, 6 monthly repayments '
        'of 172.55 in arrears mode', () {
      final calculator = Calculator()
        ..add(SeriesAdvance(value: 1000.0))
        ..add(SeriesPayment(numberOf: 6, value: 172.55, mode: Mode.arrear));
      expect(
        calculator.solveRate(dayCount: const US30360(useXirrMethod: true)),
        0.12686190609643871,
      );
    });
    test(
        'solve Act365 XIRR for loan of 1000.0, 6 monthly repayments '
        'of 172.55 in arrears mode', () {
      final calculator = Calculator()
        ..add(SeriesAdvance(
          value: 1000.0,
          postDateFrom: DateTime.utc(2022),
        ))
        ..add(SeriesPayment(
          numberOf: 6,
          value: 172.55,
          postDateFrom: DateTime.utc(2022),
          mode: Mode.arrear,
        ));
      // This result is the same as that generated by Microsoft Excel
      expect(
        calculator.solveRate(dayCount: const Act365(useXirrMethod: true)),
        0.12830319920462152,
      );
    });
  });
}
