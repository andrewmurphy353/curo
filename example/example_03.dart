import 'package:curo/curo.dart';

import 'schedule.dart';

/// Example 3: Solve Unknown Rental, Compute Lessor's IRR (Internal Rate of
/// Return)
///
/// A business enters into a 3-year finance lease for equipment costing
/// 15,000.00. Rentals are due monthly in advance. The lessor's effective
/// annual interest rate is 6.0% (see assets/images/cash_flow_diagram_03.png).
///
/// Using the Actual/Actual (ISDA) day count convention, compute the value
/// of the unknown rentals and the lessor's IRR.
///
/// Comments: Dates in this example are not defined so are derived from the
/// current system date.
///
Future<void> main() async {
  // Step 1: Instantiate calculator
  final calculator = Calculator();

  // Step 2: Define the advance, payment, and/or charge series
  calculator.add(
    SeriesAdvance(
      label: 'Equipment purchase',
      value: 15000.0,
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 36,
      label: 'Rental',
      value: null, // leave undefined or null when it is the unknown to solve
      mode: Mode.advance,
    ),
  );

  // 3. Calculate the unknown cash flow value
  final valueResult = await calculator.solveValue(
    dayCount: const ActISDA(),
    interestRate: 0.06,
  );

  // 4. Calculate the interest rate implicit in the cash flow profile
  //    (lessor's IRR) now that the profile contains the computed cash flow
  //    values rounded to the required profile precision.
  final rateImplicit = await calculator.solveRate(
    dayCount: const ActISDA(),
  );

  // 5. Print results and amortisation schedule to console
  Schedule(
    profile: calculator.profile!,
    rateResult: rateImplicit,
    valueResult: valueResult,
  ).prettyPrint(example: 3);
}
