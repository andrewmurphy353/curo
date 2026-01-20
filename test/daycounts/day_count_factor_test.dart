import 'package:curo/src/calculator.dart';
import 'package:curo/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('DayCountFactor - standard conventions', () {
    test('single operand', () {
      const factor = DayCountFactor(
        primaryPeriodFraction: 31 / 360,
        discountFactorLog: ['31/360'],
      );
      expect(factor.toString(), 'f = 31/360 = 0.08611111');
      expect(factor.toFoldedString(), 'f = 31/360 = 0.08611111');
    });

    test('multiple identical operands - folding', () {
      const factor = DayCountFactor(
        primaryPeriodFraction: 4.0,
        discountFactorLog: ['1', '1', '1', '1'],
      );
      expect(factor.toString(), 'f = 1 + 1 + 1 + 1 = 4.00000000');
      expect(factor.toFoldedString(), 'f = 4 = 4.00000000');
    });

    test('mixed fractions and whole periods', () {
      const factor = DayCountFactor(
        primaryPeriodFraction: 2 + 11 / 360,
        discountFactorLog: ['1', '1', '11/360'],
      );
      expect(factor.toString(), 'f = 1 + 1 + 11/360 = 2.03055556');
      expect(factor.toFoldedString(), 'f = 2 + 11/360 = 2.03055556');
    });

    test('fraction simplification in folding', () {
      const factor = DayCountFactor(
        primaryPeriodFraction: 2 + 2 / 365 + 31 / 365,
        discountFactorLog: ['2/365', '1', '1', '31/365'],
      );
      expect(factor.toString(), 'f = 2/365 + 1 + 1 + 31/365 = 2.09041096');
      expect(factor.toFoldedString(), 'f = 2/365 + 2 + 31/365 = 2.09041096');
    });

    test('zero period', () {
      const factor = DayCountFactor(
        primaryPeriodFraction: 0.0,
        discountFactorLog: ['0/360'],
      );
      expect(factor.toString(), 'f = 0/360 = 0.00000000');
      expect(factor.toFoldedString(), 'f = 0 = 0.00000000');
    });

    test('empty log falls back to 0', () {
      const factor = DayCountFactor(
        primaryPeriodFraction: 0.0,
        discountFactorLog: [],
      );
      expect(factor.toString(), '0');
      expect(factor.toFoldedString(), '0');
    });
  });

  group('DayCountFactor - US Appendix J', () {
    test('whole periods only', () {
      const factor = DayCountFactor(
        primaryPeriodFraction: 5.0,
        partialPeriodFraction: 0.0,
        discountTermsLog: ['t = 5', 'f = 0', 'p = 12'],
      );
      expect(factor.toString(), 't = 5 : f = 0 : p = 12');
      expect(factor.toFoldedString(), 't = 5 : f = 0 : p = 12');
    });

    test('whole + fractional', () {
      const factor = DayCountFactor(
        primaryPeriodFraction: 2.0,
        partialPeriodFraction: 5 / 30,
        discountTermsLog: ['t = 2', 'f = 5/30 = 0.16666667', 'p = 12'],
      );
      expect(factor.toString(), 't = 2 : f = 5/30 = 0.16666667 : p = 12');
      expect(factor.toFoldedString(), 't = 2 : f = 5/30 = 0.16666667 : p = 12');
    });

    test('zero whole, fractional only', () {
      const factor = DayCountFactor(
        primaryPeriodFraction: 0.0,
        partialPeriodFraction: 15 / 30,
        discountTermsLog: ['t = 0', 'f = 15/30 = 0.50000000', 'p = 12'],
      );
      expect(factor.toString(), 't = 0 : f = 15/30 = 0.50000000 : p = 12');
      expect(
        factor.toFoldedString(),
        't = 0 : f = 15/30 = 0.50000000 : p = 12',
      );
    });

    test('throws on mixed log types toString()', () {
      expect(
        () => const DayCountFactor(
          primaryPeriodFraction: 1.0,
          discountFactorLog: ['1/365'],
          discountTermsLog: ['t = 1'],
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('throws on mixed log types toFoldedString()', () {
      expect(
        () => const DayCountFactor(
          primaryPeriodFraction: 1.0,
          discountFactorLog: ['1/365'],
          discountTermsLog: ['t = 1'],
        ).toFoldedString(),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('gaussRound in formatting', () {
    test('bankers rounding applied', () {
      const fraction = 0.5 + 1 / 360; // 0.502777...
      const factor = DayCountFactor(
        primaryPeriodFraction: fraction,
        discountFactorLog: ['1/360'],
      );
      final rounded = gaussRound(fraction, 8).toStringAsFixed(8);
      expect(factor.toString(), contains(rounded));
    });
  });
}
