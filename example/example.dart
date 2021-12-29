import 'package:curo/curo.dart';

import 'schedule.dart';

/// Example 1: Solve Unknown Payment, Compute Borrower's IRR (effective rate)
///
/// An individual has applied for a loan of 10,000.00, repayable by 6 monthly
/// instalments in arrears. The lender's effective annual interest rate
/// is 8.25% (see assets/images/cash_flow_diagram_01.png).
///
/// Using the US 30/360 day count convention, compute the value of the
/// unknown instalments.
///
/// Comments: Dates in this example are not defined so are derived from the
/// current system date.
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
      numberOf: 6,
      label: 'Instalment',
      value: null, // leave undefined or null when it is the unknown to solve
      mode: Mode.arrear,
    ),
  );

  // 3. Calculate the unknown cash flow value
  final valueResult = calculator.solveValue(
    dayCount: const US30360(),
    interestRate: 0.0825,
  );

  // 4. Calculate the interest rate implicit in the cash flow profile
  //    now that the profile contains the computed cash flow values
  //    rounded to the required profile precision.
  final rateImplicit = calculator.solveRate(
    dayCount: const US30360(),
  );

  // 5. Print results and amortisation schedule to console
  Schedule(
    profile: calculator.profile!,
    rateResult: rateImplicit,
    valueResult: valueResult,
  ).prettyPrint(example: 1);
}
