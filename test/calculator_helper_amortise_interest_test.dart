import 'package:curo/src/calculator.dart';
import 'package:curo/src/calculator_helper.dart';
import 'package:curo/src/daycounts/day_count_factor.dart';
import 'package:curo/src/enums.dart';
import 'package:test/test.dart';

void main() {
  // Helper to create a simple CashFlowWithFactor
  CashFlowWithFactor cfwf({
    required CashFlowType type,
    required double amount,
    required double primaryFraction,
    bool isKnown = true,
    Mode? mode,
    bool? isInterestCapitalised,
    bool isCharge = false,
  }) {
    return CashFlowWithFactor(
      cashFlow: (
        type: type,
        postDate: DateTime.utc(2025, 1, 1),
        valueDate: DateTime.utc(2025, 1, 1),
        amount: amount,
        isKnown: isKnown,
        weighting: 1.0,
        label: '',
        mode: mode ?? Mode.arrear,
        isInterestCapitalised: isInterestCapitalised,
        isCharge: isCharge,
      ),
      factor: DayCountFactor(
        primaryPeriodFraction: primaryFraction,
        discountFactorLog: ['${primaryFraction * 12}/12'],
      ),
    );
  }

  group('amortiseInterest', () {
    test('standard loan: interest capitalised into payments, final adjustment',
        () {
      final profiled = [
        cfwf(
            type: CashFlowType.advance, amount: -10000.0, primaryFraction: 0.0),
        cfwf(
            type: CashFlowType.payment,
            amount: 1707.0,
            primaryFraction: 1 / 12,
            isInterestCapitalised: true),
        cfwf(
            type: CashFlowType.payment,
            amount: 1707.0,
            primaryFraction: 1 / 12,
            isInterestCapitalised: true),
        cfwf(
            type: CashFlowType.payment,
            amount: 1707.0,
            primaryFraction: 1 / 12,
            isInterestCapitalised: true),
        cfwf(
            type: CashFlowType.payment,
            amount: 1707.0,
            primaryFraction: 1 / 12,
            isInterestCapitalised: true),
        cfwf(
            type: CashFlowType.payment,
            amount: 1707.0,
            primaryFraction: 1 / 12,
            isInterestCapitalised: true),
        cfwf(
            type: CashFlowType.payment,
            amount: 1707.0,
            primaryFraction: 1 / 12,
            isInterestCapitalised: true),
      ];

      final result = amortiseInterest(
        profiled,
        US30360(),
        0.0825,
        2,
      ); // 8.25%, 2dp
      expect(result.map((i) => i.interest.round()),
          [0, -69, -57, -46, -35, -23, -12]);
      expect(result.map((i) => i.capitalBalance.round()),
          [-10000, -8362, -6712, -5051, -3379, -1695, 0]);

      // Final payment interest should be adjusted to force exact zero
      expect(result.last.capitalBalance, closeTo(0.0, 0.005));
      expect(result.last.interest, closeTo(-11.65, 0.005));
    });

    test('interest not capitalised: accrues separately', () {
      final profiled = [
        cfwf(
            type: CashFlowType.advance, amount: -10000.0, primaryFraction: 0.0),
        cfwf(
            type: CashFlowType.payment,
            amount: 1600.0,
            primaryFraction: 1 / 12,
            isInterestCapitalised: false),
        cfwf(
            type: CashFlowType.payment,
            amount: 1600.0,
            primaryFraction: 2 / 12,
            isInterestCapitalised: false),
      ];

      final result = amortiseInterest(profiled, US30360(), 0.12, 2);

      // Interest reported as 0.0 on payments
      expect(result[1].interest, 0.0);
      expect(result[2].interest, 0.0);

      // But capital balance only reduced by principal
      expect(result[1].capitalBalance, closeTo(-8400.0, 0.01));
      expect(result[2].capitalBalance, closeTo(-6800.0, 0.01));

      // Accrued interest is building up (though not exposed directly)
    });

    test('final payment absorbs rounding error even with charges', () {
      final profiled = [
        cfwf(
            type: CashFlowType.advance, amount: -10000.0, primaryFraction: 0.0),
        cfwf(
            type: CashFlowType.payment,
            amount: 1700.0,
            primaryFraction: 1 / 12,
            isInterestCapitalised: true),
        cfwf(
            type: CashFlowType.charge,
            amount: 100.0,
            primaryFraction: 0.0, // Always zero for useXirrMethod = false,
            isCharge: true),
        cfwf(
            type: CashFlowType.payment,
            amount: 1700.0,
            primaryFraction: 1 / 12,
            isInterestCapitalised: true),
        cfwf(
            type: CashFlowType.payment,
            amount: 1700.0,
            primaryFraction: 1 / 12,
            isInterestCapitalised: true),
      ];

      final result = amortiseInterest(profiled, US30360(includeNonFinancingFlows: true), 0.06, 2);
      
      // First payment before same-dated charge
      expect(result[1].interest.round(), -50.0);
      expect(result[1].capitalBalance, closeTo(-8350.0, 0.01)); // -10000 -50 + 1700 = ~ -8350
      // Charge
      expect(result[2].interest, 0.0); // Always zero for useXirrMethod = false,
      expect(result[2].capitalBalance.round(), -8250); // -8350 -0 +100 = ~ -8250
      // Second payment one month later
      expect(result[3].interest.round(), -41.0);
      expect(result[3].capitalBalance.round(), -6591); // -8250 - 41 + 1700 = ~ -6591
      // Final payment, monthly interest ~32.96, however interest takes account
      // of rounding differences so adjusts to bring balance => zero
      expect(result.last.interest.round(), 4891); // -6591 +1700 = ~ 4891 (includes ~33 monthly interest)
      // Ensure balance is exactly zero despite prior rounding
      expect(result.last.capitalBalance, closeTo(0.0, 1e-6));
    });

    test('interest accrues on advance before first payment', () {
      final profiled = [
        cfwf(
            type: CashFlowType.advance, amount: -10000.0, primaryFraction: 0.0),
        cfwf(
            type: CashFlowType.advance,
            amount: -5000.0,
            primaryFraction: 0.0833), // 1 month later
        cfwf(
            type: CashFlowType.payment,
            amount: 2000.0,
            primaryFraction: 0.0833,
            isInterestCapitalised: true),
        cfwf(
            type: CashFlowType.payment,
            amount: 2000.0,
            primaryFraction: 0.0833,
            isInterestCapitalised: true),
      ];

      final result = amortiseInterest(profiled, US30360(), 0.12, 2);
      // First advance accrues one month of interest before second advance [10000 * 0.12 * 1/12 ~ 100 int]
      // Then both accrue another month before payment [(10000 + 5000) * 0.12 * 1/12 ~ 150 int]
      final expectedInterest = closeTo(-250.0, 0.1); // 100 + 150 ~ 250

      expect(result[2].interest, expectedInterest);
      expect(result[2].capitalBalance,
          closeTo(-15000.0 - 250 + 2000.0, 1.0)); // rough
    });

    test('no final adjustment when no capitalised payments', () {
      final profiled = [
        cfwf(
            type: CashFlowType.advance, amount: -10000.0, primaryFraction: 0.0),
        cfwf(
            type: CashFlowType.payment,
            amount: 5000.0,
            primaryFraction: 1.0,
            isInterestCapitalised: false),
      ];

      final result = amortiseInterest(profiled, US30360(), 0.10, 2);

      // No adjustment attempted
      expect(result.last.interest, 0.0);
      expect(result.last.capitalBalance, closeTo(-5000.0, 0.01));
    });

    test('handles zero rate gracefully', () {
      final profiled = [
        cfwf(
            type: CashFlowType.advance, amount: -10000.0, primaryFraction: 0.0),
        cfwf(
            type: CashFlowType.payment,
            amount: 10000.0,
            primaryFraction: 1.0,
            isInterestCapitalised: true),
      ];

      final result = amortiseInterest(profiled, US30360(), 0.0, 2);

      expect(result[1].interest, 0.0);
      expect(result[1].capitalBalance, 0.0);
    });
  });
}
