import 'dart:mirrors';

import 'package:curo/src/calculator.dart';
import 'package:test/test.dart';

void main() async {
  group('Calculator developer exceptions', () {
    test('invalid precision: too high', () {
      expect(
        () => Calculator(precision: 5),
        throwsA(isA<DeveloperException>()),
      );
    });
    test('invalid precision: negative', () {
      expect(
        () => Calculator(precision: -1),
        throwsA(isA<DeveloperException>()),
      );
    });
    test('profile not yet created', () {
      expect(
        () => Calculator()..profile,
        throwsA(isA<DeveloperException>()),
      );
    });
    test('solveValue: interest rate negative', () {
      final calculator = Calculator()..add(SeriesAdvance());
      expect(
        () => calculator.solveValue(convention: US30360(), interestRate: -0.1),
        throwsA(isA<DeveloperException>()),
      );
    });
    test('buildSchedule: interest rate negative', () {
      expect(
        () => Calculator()
          ..buildSchedule(convention: US30360(), interestRate: -0.1),
        throwsA(isA<DeveloperException>()),
      );
    });
    test('buildSchedule: profile null', () {
      expect(
        () => Calculator()
          ..buildSchedule(convention: US30360(), interestRate: 0.1),
        throwsA(isA<DeveloperException>()),
      );
    });
  });
  group('add series', () {
    test('coerce rounding to 3dp', () {
      final calculator = Calculator(precision: 3)
        ..add(SeriesAdvance(amount: 100.12345));

      final calcIM = reflect(calculator);
      final seriesSymbol = calcIM.type.instanceMembers.values
          .firstWhere(
              (decl) => MirrorSystem.getName(decl.simpleName) == '_series')
          .simpleName;
      var value = calcIM.getField(seriesSymbol).reflectee;
      final advance = value[0] as SeriesAdvance;
      expect(advance.amount, 100.123);
    });
  });
  group('multiple advance example', () {
    final calculator = Calculator()
      ..add(SeriesAdvance(
        numberOf: 2,
        label: 'Loan',
        amount: 5000,
        frequency: Frequency.quarterly,
      ))
      ..add(SeriesPayment(
        numberOf: 12,
        label: 'Instalment',
        amount: null,
      ))
      ..add(SeriesCharge(
        label: 'Fee',
        amount: 100,
        mode: Mode.arrear,
      ));
    test('including charges : includeNonFinancingFlows: true', () async {
      final convention = US30U360(includeNonFinancingFlows: true);
      final pmt = await calculator.solveValue(
          convention: convention, interestRate: 0.1);
      final irr = await calculator.solveRate(convention: convention);
      final schedule =
          calculator.buildSchedule(convention: convention, interestRate: irr);

      expect(pmt, closeTo(852.53, 0.01));
      expect(irr, closeTo(0.10001192, 1e-8));
      // Expected output as multi-line string
      const expected = '''
post_date    label                            amount        capital       interest  capital_balance
---------------------------------------------------------------------------------------------------
2026-01-20   Loan                          -5,000.00      -5,000.00           0.00        -5,000.00
2026-01-20   Instalment                       852.53         852.53           0.00        -4,147.47
2026-02-20   Instalment                       852.53         817.96         -34.57        -3,329.51
2026-02-20   Fee                              100.00         100.00           0.00        -3,229.51
2026-03-20   Instalment                       852.53         825.61         -26.92        -2,403.90
2026-04-20   Loan                          -5,000.00      -5,000.00           0.00        -7,403.90
2026-04-20   Instalment                       852.53         832.50         -20.03        -6,571.40
2026-05-20   Instalment                       852.53         797.76         -54.77        -5,773.64
2026-06-20   Instalment                       852.53         804.41         -48.12        -4,969.23
2026-07-20   Instalment                       852.53         811.11         -41.42        -4,158.12
2026-08-20   Instalment                       852.53         817.87         -34.66        -3,340.25
2026-09-20   Instalment                       852.53         824.69         -27.84        -2,515.56
2026-10-20   Instalment                       852.53         831.56         -20.97        -1,684.00
2026-11-20   Instalment                       852.53         838.49         -14.04          -845.51
2026-12-20   Instalment                       852.53         845.51          -7.02             0.00
''';
      await expectLater(
          () => schedule.prettyPrint(convention: convention), prints(expected));
    });
    test('excluding charges : includeNonFinancingFlows: false', () async {
      final convention = US30U360(includeNonFinancingFlows: false); //default
      final pmt = await calculator.solveValue(
          convention: convention, interestRate: 0.1);
      final irr = await calculator.solveRate(convention: convention);
      final schedule =
          calculator.buildSchedule(convention: convention, interestRate: irr);

      expect(pmt, closeTo(861.17, 0.01));
      expect(irr, closeTo(0.09998714, 1e-8));
      // Expected output as multi-line string
      const expected = '''
post_date    label                            amount        capital       interest  capital_balance
---------------------------------------------------------------------------------------------------
2026-01-20   Loan                          -5,000.00      -5,000.00           0.00        -5,000.00
2026-01-20   Instalment                       861.17         861.17           0.00        -4,138.83
2026-02-20   Instalment                       861.17         826.68         -34.49        -3,312.15
2026-03-20   Instalment                       861.17         833.57         -27.60        -2,478.58
2026-04-20   Loan                          -5,000.00      -5,000.00           0.00        -7,478.58
2026-04-20   Instalment                       861.17         840.52         -20.65        -6,638.06
2026-05-20   Instalment                       861.17         805.86         -55.31        -5,832.20
2026-06-20   Instalment                       861.17         812.57         -48.60        -5,019.63
2026-07-20   Instalment                       861.17         819.35         -41.82        -4,200.28
2026-08-20   Instalment                       861.17         826.17         -35.00        -3,374.11
2026-09-20   Instalment                       861.17         833.06         -28.11        -2,541.05
2026-10-20   Instalment                       861.17         840.00         -21.17        -1,701.05
2026-11-20   Instalment                       861.17         847.00         -14.17          -854.05
2026-12-20   Instalment                       861.17         854.05          -7.12             0.00
''';
      await expectLater(
          () => schedule.prettyPrint(convention: convention), prints(expected));
    });
  });
}
