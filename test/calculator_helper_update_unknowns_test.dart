import 'package:curo/src/calculator_helper.dart';
import 'package:curo/src/daycounts/day_count_factor.dart';
import 'package:curo/src/enums.dart';
import 'package:test/test.dart';

void main() {
  CashFlowWithFactor cfwf(double amount, double weighting, bool isKnown) =>
      CashFlowWithFactor(
        cashFlow: (
          type: CashFlowType.payment,
          postDate: DateTime.utc(2026, 1, 1),
          valueDate: DateTime.utc(2026, 1, 1),
          amount: amount,
          isKnown: isKnown,
          weighting: weighting,
          label: '',
          mode: Mode.arrear,
          isInterestCapitalised: true,
          isCharge: false,
        ),
        factor: const DayCountFactor(primaryPeriodFraction: 0.0),
      );

  group('updateUnknowns', () {
    test('applies per-unit amount with weighting and preserves sign', () {
      final profiled = [
        cfwf(1000.0, 1.0, true), // known
        cfwf(0.0, 2.0, false), // unknown, positive
        cfwf(-500.0, 0.5, false), // unknown, negative base
      ];

      final result = updateUnknowns(
          profiled: profiled, perUnitAmount: 100.0, precision: 2);

      expect(result.map((r) => r.cashFlow.amount), [1000.0, 200.0, -50.0]);
      expect(result.map((r) => r.cashFlow.isKnown), [true, true, true]);
    });

    test('no rounding when precision null', () {
      final profiled = [cfwf(0.0, 1.0 / 3.0, false)];
      final result = updateUnknowns(
          profiled: profiled, perUnitAmount: 100.0, precision: null);
      expect(result[0].cashFlow.amount, closeTo(33.33333333, 1e-8));
    });

    test('returns original list when no unknowns', () {
      final profiled = [cfwf(500.0, 1.0, true)];
      final result = updateUnknowns(profiled: profiled, perUnitAmount: 100.0);
      expect(identical(result, profiled), isTrue);
    });
  });
}
