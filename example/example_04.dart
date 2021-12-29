import 'package:curo/curo.dart';

import 'schedule.dart';

/// Example 4: Solve Unknown Rental, Compute Lessor's XIRR (eXtended Internal
/// Rate of Return)
///
/// A business enters into a 2-year operating lease for equipment costing
/// 25,000.00. Rentals are due monthly in advance followed by a 15,000.00
/// purchase option (future value). The lessor's effective annual interest
/// rate is 5.0% (see assets/images/cash_flow_diagram_04.png).
///
/// Using the US 30/360 day count convention, compute the value of the
/// unknown rentals and the lessor's XIRR.
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
      value: 25000.0,
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 24,
      label: 'Rental',
      value: null, // leave undefined or null when it is the unknown to solve
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 1,
      label: 'Purchase option',
      value: 15000.0,
    ),
  );

  // 3. Calculate the unknown cash flow value
  final valueResult = calculator.solveValue(
    dayCount: const US30360(),
    interestRate: 0.05,
  );

  // 4. Calculate the interest rate implicit in the cash flow profile
  //    (lessor's XIRR) now that the profile contains the computed cash flow
  //    values rounded to the required profile precision.
  final rateImplicit = calculator.solveRate(
    dayCount: const US30360(useXirrMethod: true),
  );

  // 5. Print results and XIRR proof schedule to console
  Schedule(
    profile: calculator.profile!,
    rateResult: rateImplicit,
    valueResult: valueResult,
  ).prettyPrint(example: 4);
}
