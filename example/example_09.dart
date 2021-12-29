import 'package:curo/curo.dart';

import 'schedule.dart';

/// Example 9: Solve Unknown Rental, Loaded First Rental
///
/// A business enters into a 3-year finance lease for equipment costing
/// 10,000.00. Rentals are due monthly with the first 3 rentals due
/// upfront, followed by the remaining 33 monthly rentals due in arrears.
/// The lessor's effective annual interest rate is 7.0%
/// (see assets/images/cash_flow_diagram_09.png).
///
/// Using the US 30/360 day count convention, compute the value of the
/// unknown rental and the lessor's IRR.
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
      label: 'Equipment purchase',
      value: 10000.0,
    ),
  );
  calculator.add(
    // 1 rental weighted by 3.0 is equivalent to 3 rentals paid together.
    SeriesPayment(
      numberOf: 1,
      label: 'Rental',
      value: null, // leave undefined or null when it is the unknown to solve
      weighting: 3.0,
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 33,
      label: 'Rental',
      value: null, // leave undefined or null when it is the unknown to solve
      mode: Mode.arrear,
    ),
  );

  // 3. Calculate the unknown cash flow value
  final valueResult = calculator.solveValue(
    dayCount: const US30360(),
    interestRate: 0.07,
  );

  // 4. Calculate the interest rate implicit in the cash flow profile
  //    (lessor's IRR) now that the profile contains the computed cash flow
  //    values rounded to the required profile precision.
  final rateImplicit = calculator.solveRate(
    dayCount: const US30360(),
  );

  // 5. Print results and amortisation schedule to console
  Schedule(
    profile: calculator.profile!,
    rateResult: rateImplicit,
    valueResult: valueResult,
  ).prettyPrint(example: 9);
}
