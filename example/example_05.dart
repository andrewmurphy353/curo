import 'package:curo/curo.dart';
import 'package:curo/src/utilities/dates.dart';

import 'schedule.dart';

/// Example 5: Solve Unknown Payment with Irregular Interest Compounding
///
/// An individual secures a loan of 10,000.00 repayable by 36 monthly
/// instalments in arrears. The lender's effective annual interest rate
/// is 8.25% and interest is compounded quarterly (not monthly)
/// (see assets/images/cash_flow_diagram_05.png).
///
/// Using the US 30/360 day count convention, compute the value of the
/// unknown instalments/repayments and the lender's IRR.
///
/// Comments: This example introduces a powerful feature of the calculator,
/// and that is you are permitted to define your own start dates for each
/// series you define. This enables you to interweave two or more series
/// to create a hybrid cash flow series with different property sets;
/// and this is the approach used to solve this particular problem.
/// - First, define a monthly payment cash flow series and set
///   isInterestCapitalised:false to override interest capitalisation
///   in this series.
/// - Next, define a cash flow series for the quarterly interest accruals,
///   assign a zero payment value, and set isInterestCapitalised:true to
///   turn interest capitalisation on in this series (this is actually on
///   by default).
/// As you may expect given the same start dates, the date of each interest
/// cash flow will coincide with the date of every third payment cash flow
/// when both series are interwoven, and this is exactly what you will see
/// when you review the amortisation schedule produced with the results.
///
Future<void> main() async {
  // Step 1: Instantiate calculator
  final calculator = Calculator();
  final today = utcDate(DateTime.now());

  // Step 2: Define the advance, payment, and/or charge series
  calculator.add(
    SeriesAdvance(
      label: 'Loan',
      value: 10000.0,
      postDateFrom: today,
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 36,
      label: 'Instalment',
      value: null, // leave undefined or null when it is the unknown to solve
      mode: Mode.arrear,
      postDateFrom: today,
      isInterestCapitalised: false,
      // Important to override default true as the next series takes care
      // of the interest
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 12,
      label: 'Interest',
      value: 0.0,
      // Important to set repayment value to zero as there is no capital
      // repaid in this series
      frequency: Frequency.quarterly,
      mode: Mode.arrear,
      postDateFrom: today,
    ),
  );

  // 3. Calculate the unknown cash flow value
  final valueResult = await calculator.solveValue(
    dayCount: const US30360(),
    interestRate: 0.0825,
  );

  // 4. Calculate the lender's IRR.
  final rateImplicit = await calculator.solveRate(
    dayCount: const US30360(),
  );

  // 5. Print results and amortisation schedule to console
  Schedule(
    profile: calculator.profile!,
    rateResult: rateImplicit,
    valueResult: valueResult,
  ).prettyPrint(example: 5);
}
