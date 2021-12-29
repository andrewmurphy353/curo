import 'package:curo/curo.dart';

import 'schedule.dart';

/// Example 8: Solve Unknown Payment, Stepped Repayment Profile
///
/// An individual secures a loan of 10,000.00 repayable by 36 monthly
/// instalments in arrears on a stepped profile. The instalments
/// payable in each successive year are to be stepped at the
/// ratio 1.0 : 0.6 : 0.4 to accelerate capital recovery in earlier
/// years. The lender's effective annual interest rate is 7.0%
/// (see assets/images/cash_flow_diagram_08.png).
///
/// Using the US 30/360 day count convention, compute the value of the
/// unknown (fully weighted) instalment and the borrower's APR.
///
/// Comments: Cash flow series dates in this example are defined with
/// reference to the current system date.
///
void main() {
  // Step 1: Instantiate calculator
  final calculator = Calculator();

  // Step 2: Define the advance, payment, and/or charge series
  calculator.add(
    SeriesAdvance(
      label: 'Loan',
      value: 10000.0,
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 12,
      label: 'Instalment',
      value: null, // leave undefined or null when it is the unknown to solve
      mode: Mode.arrear,
      weighting: 1.0, // 100% of the unknown payment value (fully weighted)
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 12,
      label: 'Instalment',
      value: null, // leave undefined or null when it is the unknown to solve
      mode: Mode.arrear,
      weighting: 0.6, // 60% of the unknown payment value
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 12,
      label: 'Instalment',
      value: null, // leave undefined or null when it is the unknown to solve
      mode: Mode.arrear,
      weighting: 0.4, // 40% of the unknown payment value
    ),
  );

  // 3. Calculate the unknown cash flow value
  final valueResult = calculator.solveValue(
    dayCount: const US30360(),
    interestRate: 0.07,
  );

  // 4. Calculate the borrower's APR.
  final rateImplicit = calculator.solveRate(
    dayCount: const EU200848EC(),
  );

  // 5. Print results and APR calculation proof to console
  Schedule(
    profile: calculator.profile!,
    rateResult: rateImplicit,
    valueResult: valueResult,
  ).prettyPrint(example: 8);
}
