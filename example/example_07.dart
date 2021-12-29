import 'package:curo/curo.dart';
import 'package:curo/src/utilities/dates.dart';

import 'schedule.dart';

/// Example 7: Compute Supplier Contribution, 0% Interest Finance Promotion
/// and incorporating a 30 Day Deferred Settlement.
///
/// A car dealership offers an individual 0% finance on a car costing
/// 20,400.00. An upfront deposit of 6000.00 is payable, followed by
/// 36 monthly instalments of 400.00 in arrears. Finance is provided by
/// a third party lender at an effective annual interest rate of 5.0%. The
/// supplier agrees with the lender to make an *undisclosed* contribution
/// to cover the cost of finance, and furthermore offers the lender 30 day
/// settlement terms (see assets/images/cash_flow_diagram_07.png).
///
/// Using the US 30/360 day count convention, compute the value of the
/// unknown contribution and the lessor's IRR.
///
/// Comments: Cash flow series dates in this example are defined with
/// reference to the current system date. The example also confirms the
/// total paid by the borrower (excluding the *undisclosed*
/// supplier contribution/discount) equals the cash price of the car
/// irrespective of when the supplier is paid. It also demonstrates that
/// deferred settlement calculations performed from the lender's perspective
/// should be undertaken using cash flow *value dates*.
///
void main() {
  // Step 1: Instantiate calculator
  final calculator = Calculator();
  final today = utcDate(DateTime.now());

  // Step 2: Define the advance, payment, and/or charge series
  calculator.add(
    SeriesAdvance(
      label: 'Cost of car',
      value: 20400.0,
      postDateFrom: today,
      valueDateFrom: rollDay(today, 30), //settle 30 days from today
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
      postDateFrom: rollDay(today, 30),
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
  //    Note: the calculation is performed with reference to the cash flow
  //    *value* dates as that is when interest starts accruing from the
  //    lender perspective.
  final valueResult = calculator.solveValue(
    dayCount: const US30360(usePostDates: false),
    interestRate: 0.05,
  );

  // 4. Calculate the interest rate implicit in the cash flow profile
  //    (lender's IRR) now that the profile contains the computed cash flow
  //    values rounded to the required profile precision.
  //    Note: the IRR calculation is performed with reference to the cash flow
  //    *value* dates as that is when interest starts accruing from the
  //    lender perspective.
  final rateImplicit = calculator.solveRate(
    dayCount: const US30360(usePostDates: false),
  );

  // 5. Print results and amortisation schedule to console
  Schedule(
    profile: calculator.profile!,
    rateResult: rateImplicit,
    valueResult: valueResult,
  ).prettyPrint(example: 7);
}
