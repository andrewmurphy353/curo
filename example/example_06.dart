import 'package:curo/curo.dart';
import 'package:curo/src/utilities/dates.dart';

import 'schedule.dart';

/// Example 6: Compute Supplier Contribution, 0% Interest Finance Promotion.
///
/// A car dealership offers an individual 0% finance on a car costing
/// 20,400.00. An upfront deposit of 6000.00 is payable, followed by
/// 36 monthly instalments of 400.00 in arrears. Finance is provided by
/// a third party lender at an effective annual interest rate of 5.0%. The
/// supplier agrees with the lender to make an *undisclosed* contribution
/// to cover the cost of finance (see assets/images/cash_flow_diagram_06.png).
///
/// Using the US 30/360 day count convention, compute the value of the
/// unknown contribution and the lessor's IRR.
///
/// Comments: Cash flow series dates in this example are defined with
/// reference to the current system date. This example also confirms the
/// total paid by the borrower (excluding the *undisclosed* supplier
/// contribution/discount) equals the cash price of the car i.e. borrower
/// pays no interest.
///
Future<void> main() async {
  // Step 1: Instantiate calculator
  final calculator = Calculator();
  final today = utcDate(DateTime.now());

  // Step 2: Define the advance, payment, and/or charge series
  calculator.add(
    SeriesAdvance(
      label: 'Cost of car',
      value: 20400.0,
      postDateFrom: today,
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 1,
      label: 'Deposit',
      value: 6000.0,
      postDateFrom: today,
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 1,
      label: 'Supplier contribution (undisclosed)',
      value: null, // leave undefined or null when it is the unknown to solve
      postDateFrom: today,
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 36,
      label: 'Instalment',
      value: 400.0,
      mode: Mode.arrear,
      postDateFrom: today,
    ),
  );

  // 3. Calculate the unknown cash flow value
  final valueResult = await calculator.solveValue(
    dayCount: const US30360(),
    interestRate: 0.05,
  );

  // 4. Calculate the interest rate implicit in the cash flow profile
  //    (lender's IRR) now that the profile contains the computed cash flow
  //    values rounded to the required profile precision.
  final rateImplicit = await calculator.solveRate(
    dayCount: const US30360(),
  );

  // 5. Print results and amortisation schedule to console
  Schedule(
    profile: calculator.profile!,
    rateResult: rateImplicit,
    valueResult: valueResult,
  ).prettyPrint(example: 6);
}
