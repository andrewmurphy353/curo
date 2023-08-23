import 'package:curo/curo.dart';
import 'package:curo/src/core/solve_cashflow.dart';
import 'package:curo/src/profile/helper.dart';
import 'package:test/test.dart';

void main() {
  group('SolveCashFlow', () {
    test(
        'using regular compounding and DayCountOrigin.neighbour time '
        'periods returns NFV of ~0.00 for expected 340.02 payment', () {
      var profile = Profile(
        cashFlows: [
          CashFlowAdvance(postDate: DateTime.utc(2022, 1, 1), value: -1000.0),
          CashFlowPayment(postDate: DateTime.utc(2022, 2, 1), isKnown: false),
          CashFlowPayment(postDate: DateTime.utc(2022, 3, 1), isKnown: false),
          CashFlowPayment(postDate: DateTime.utc(2022, 4, 1), isKnown: false),
          CashFlowCharge(postDate: DateTime.utc(2022, 1, 1), value: 10.0),
        ],
        dayCount: const US30360(),
      );
      profile = assignFactors(profile);
      final payment = SolveCashFlow(profile: profile, effectiveRate: 0.12);
      expect(payment.compute(340.02), -0.006398000000046977);
    });
  });
}
