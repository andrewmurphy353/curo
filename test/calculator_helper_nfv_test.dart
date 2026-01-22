import 'package:curo/src/calculator_helper.dart';
import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/enums.dart';
import 'package:test/test.dart';

void main() {
  final d0 = DateTime.utc(2026, 1, 1);
  final d1 = DateTime.utc(2026, 2, 1);

  CashFlowWithFactor cfwf(double amount, double fraction) => CashFlowWithFactor(
        cashFlow: (
          type: amount < 0 ? CashFlowType.advance : CashFlowType.payment,
          postDate: amount < 0 ? d0 : d1,
          valueDate: amount < 0 ? d0 : d1,
          amount: amount,
          isKnown: true,
          weighting: 1.0,
          label: '',
          mode: Mode.arrear,
          isInterestCapitalised: true,
        ),
        factor: DayCountFactor(primaryPeriodFraction: fraction),
      );

  group('nfv', () {
    test('XIRR mode: continuous compounding', () {
      final profiled = [
        cfwf(-1000.0, 0.0),
        cfwf(1100.0, 1.0),
      ];
      final result = nfv(
          profiled: profiled,
          rate: 0.1,
          convention: const US30360(useXirrMethod: true));
      expect(result, closeTo(0.0, 1e-6)); // 1000 * (1.1) ≈ 1100
    });

    test('Neighbour mode: simple period compounding', () {
      final profiled = [
        cfwf(-1000.0, 0.0),
        cfwf(1050.0, 0.5), // half year
      ];
      final result =
          nfv(profiled: profiled, rate: 0.1, convention: const US30360());
      expect(result, closeTo(0.0, 1e-6)); // 1000 * (1 + 0.1 * 0.5) = 1050
    });

    test('excludes charges when flag false', () {
      final profiled = [
        cfwf(-1000.0, 0.0),
        CashFlowWithFactor(
          cashFlow: (
            type: CashFlowType.charge,
            postDate: d0,
            valueDate: d0,
            amount: 50.0,
            isKnown: true,
            weighting: 1.0,
            label: '',
            mode: Mode.arrear,
            isInterestCapitalised: null,
          ),
          factor: const DayCountFactor(primaryPeriodFraction: 1 / 12),
        ),
        cfwf(1007.92, 1 / 12),
      ];
      final result = nfv(
          profiled: profiled,
          rate: 0.095,
          convention: const US30360(includeNonFinancingFlows: false));
      expect(result, closeTo(0.0, 1e-2)); // ignores the 50 charge
    });
  });
}
