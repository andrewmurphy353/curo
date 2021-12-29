import 'package:curo/curo.dart';

import 'schedule.dart';

/// Example 2: Solve Unknown Payment, Compute Borrower's APR (Annual
/// Percentage Rate) including the fee.
///
/// An individual has applied for a loan of 10,000.00, repayable by
/// 6 monthly instalments in arrears. A fee of 50.0 is payable with the
/// first instalment. The lender's effective annual interest rate is 8.25%
/// (see assets/images/cash_flow_diagram_02.png).
///
/// Using the US 30/360 day count convention, compute the value of the
/// unknown instalments/repayments and the borrower's APR.
///
/// Comments: In the example the APR is computed in compliance
/// with the European Union Consumer Credit Directive EU2008/49/EC. The
/// directive requires the APR to reflect the total cost of credit, which
/// in a nutshell requires all financing cash flows, plus any non-financing
/// cash flows linked to the credit agreement such as charges and fees, to be
/// included in the calculation. Nothing controversial here.
///
/// But what if you are not in the European Union and want to achieve the
/// same affect?
///
/// In such cases you should compute the XIRR (eXtended Internal Rate of
/// Return) implicit in the cash flow series using any of the other
/// day count convention options, and set useXirrMethod:true. This will
/// produce a result that is similar, if not exactly the same.
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
  calculator.add(
    SeriesCharge(
      label: 'Fee',
      value: 50.0,
      mode: Mode.arrear,
    ),
  );

  // 3. Calculate the unknown cash flow value
  final valueResult = calculator.solveValue(
    dayCount: const US30360(),
    interestRate: 0.0825,
  );

  // 4. Calculate the APR.
  final rateImplicit = calculator.solveRate(
    dayCount: const EU200848EC(),
  );

  // 5. Print results and APR calculation proof to console
  Schedule(
    profile: calculator.profile!,
    rateResult: rateImplicit,
    valueResult: valueResult,
  ).prettyPrint(example: 2);
}
