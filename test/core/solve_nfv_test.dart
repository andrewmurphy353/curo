import 'package:curo/curo.dart';
import 'package:curo/src/core/solve_nfv.dart';
import 'package:test/test.dart';

void main() {
  group('SolveNfv', () {
    test(
        'using regular compounding and DayCountOrigin.neighbour time '
        'periods returns ~0.00 at 12.00%', () {
      var profile = Profile(
        cashFlows: [
          CashFlowAdvance(postDate: DateTime.utc(2022, 1, 1), value: -1000.0),
          CashFlowPayment(postDate: DateTime.utc(2022, 2, 1), value: 340.02),
          CashFlowPayment(postDate: DateTime.utc(2022, 3, 1), value: 340.02),
          CashFlowPayment(postDate: DateTime.utc(2022, 4, 1), value: 340.02),
          CashFlowCharge(postDate: DateTime.utc(2022, 1, 1), value: 10.0),
        ],
        dayCount: const US30360(),
      );
      profile = assignFactors(profile);
      final solveNfv = SolveNfv(profile: profile);
      expect(solveNfv.compute(0.12), -0.006398000000046977);
    });
    test(
        'using irregular compounding and DayCountOrigin.neighbour time '
        'periods returns ~0.00 at 12.16%', () {
      var profile = Profile(
        cashFlows: [
          CashFlowAdvance(postDate: DateTime.utc(2022, 1, 1), value: -1000.0),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 2, 1),
            value: 340.02,
            isInterestCapitalised: false,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 340.02,
            isInterestCapitalised: false,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 4, 1),
            value: 340.02,
          ),
          CashFlowCharge(postDate: DateTime.utc(2022, 1, 1), value: 10.0),
        ],
        dayCount: const US30360(),
      );
      profile = assignFactors(profile);
      final solveNfv = SolveNfv(profile: profile);
      expect(solveNfv.compute(0.1216), -0.003392000000076223);
    });
    test(
        'using regular compounding and DayCountOrigin.drawdown time '
        'periods returns ~0.00 at 19.71% (XIRR)', () {
      var profile = Profile(
        cashFlows: [
          CashFlowAdvance(postDate: DateTime.utc(2022, 1, 1), value: -1000.0),
          CashFlowPayment(postDate: DateTime.utc(2022, 2, 1), value: 340.02),
          CashFlowPayment(postDate: DateTime.utc(2022, 3, 1), value: 340.02),
          CashFlowPayment(postDate: DateTime.utc(2022, 4, 1), value: 340.02),
          CashFlowCharge(postDate: DateTime.utc(2022, 1, 1), value: 10.0),
        ],
        dayCount: const US30360(
          includeNonFinancingFlows: true,
          useXirrMethod: true,
        ),
      );
      profile = assignFactors(profile);
      final solveNfv = SolveNfv(profile: profile);
      expect(solveNfv.compute(0.1971), 0.0030105880029509535);
    });
    test(
        'using irregular compounding and DayCountOrigin.drawdown time '
        'periods returns ~0.00 at 12.68% (XIRR)', () {
      var profile = Profile(
        cashFlows: [
          CashFlowAdvance(postDate: DateTime.utc(2022, 1, 1), value: -1000.0),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 2, 1),
            value: 340.02,
            isInterestCapitalised: false,
          ),
          CashFlowPayment(
            postDate: DateTime.utc(2022, 3, 1),
            value: 340.02,
            isInterestCapitalised: false,
          ),
          CashFlowPayment(postDate: DateTime.utc(2022, 4, 1), value: 340.02),
          CashFlowCharge(postDate: DateTime.utc(2022, 1, 1), value: 10.0),
        ],
        dayCount: const US30360(
          includeNonFinancingFlows: false,
          useXirrMethod: true,
        ),
      );
      profile = assignFactors(profile);
      final solveNfv = SolveNfv(profile: profile);
      expect(solveNfv.compute(0.1268), -0.0025199269198878937);
    });
  });
}
