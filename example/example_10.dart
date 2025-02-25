import 'package:curo/curo.dart';

import 'schedule.dart';

/// Example 10: Solve unknown payments, multiple-interest rate repayment
/// schedule e.g. fixed-to-variable rate mortgage loan.
///
/// Note this is just a PROOF OF CONCEPT to demonstrate how this library could
/// be used to perform these calculations. Be warned though that solving for
/// unknowns in these types of financial products are computationally very
/// expensive as the steps require multiple calculations!
///
/// The approach illustrated below works for solving unknown payments using
/// Nominal Annual Rates, but not APRs. A better approach would be to modify
/// step 2 by discounting the fixed repayments 61 to 360 of step 1 using
/// the 3.25% fixed rate of interest, and use the result as the advance in
/// step 3 when calculating the variable payments. This will work using either
/// NAR or APR day count conventions. In this example we have not considered
/// charges or multiple drawdowns, or any of the other (advanced) features built
/// into this library as these add yet another layer of complexity.
///
Future<void> main() async {
  final startTime = DateTime.now();
  print('Calculator started: $startTime');

  const loanAmount = 300000.0;
  const fixedRate = 0.0325;
  const variableRate = 0.045;

  final contractStart = utcDate(DateTime.now());
  final fixedPaymentStart = rollMonth(
    contractStart,
    1,
    contractStart.day,
  );
  final variablePeriodStart = rollMonth(
    contractStart,
    60,
    contractStart.day,
  );
  final variablePaymentStart = rollMonth(
    variablePeriodStart,
    1,
    variablePeriodStart.day,
  );

  // ==========================================
  // Step 1: Determine the fixed period payment
  // ==========================================
  final fixedPmtCalc = Calculator();
  fixedPmtCalc.add(
    SeriesAdvance(
      label: 'Home mortgage loan',
      value: loanAmount,
      postDateFrom: contractStart,
    ),
  );
  fixedPmtCalc.add(
    SeriesPayment(
      numberOf: 360, // [60 months fixed, 300 variable]
      label: 'Payment',
      value: null, // Unknown fixed payment (1305.62 @ 3.250006%)
      isInterestCapitalised: false,
      frequency: Frequency.monthly,
      postDateFrom: fixedPaymentStart,
    ),
  );
  fixedPmtCalc.add(
    SeriesPayment(
      numberOf: 120,
      label: 'Interest',
      value: 0.0,
      isInterestCapitalised: true,
      frequency: Frequency.quarterly,
      postDateFrom: rollMonth(contractStart, 3, contractStart.day),
    ),
  );
  final fixedPayment = await fixedPmtCalc.solveValue(
    dayCount: const US30360(),
    interestRate: fixedRate,
  );

  // ==============================================
  // Step 2: Determine the fixed period end balance
  // ==============================================
  final endBalFixedPeriodCalc = Calculator();
  endBalFixedPeriodCalc.add(
    SeriesAdvance(
      label: 'Home mortgage loan',
      value: 300000.0,
      postDateFrom: contractStart,
    ),
  );
  endBalFixedPeriodCalc.add(
    SeriesPayment(
      numberOf: 60, // [60 months fixed, 300 variable]
      label: 'Fixed payment',
      value: fixedPayment,
      isInterestCapitalised: false,
      frequency: Frequency.monthly,
      postDateFrom: fixedPaymentStart,
    ),
  );
  endBalFixedPeriodCalc.add(
    SeriesPayment(
      numberOf: 20,
      label: 'Interest',
      value: 0.0,
      isInterestCapitalised: true,
      frequency: Frequency.quarterly,
      postDateFrom: rollMonth(contractStart, 3, contractStart.day),
    ),
  );
  endBalFixedPeriodCalc.add(
    SeriesPayment(
      numberOf: 1,
      label: 'Fixed period end balance',
      value: null, //to be determined
      frequency: Frequency.monthly,
      postDateFrom: variablePeriodStart,
    ),
  );
  final fixedPeriodBalance = await endBalFixedPeriodCalc.solveValue(
    dayCount: const US30360(),
    interestRate: fixedRate,
  );

  // ======================================
  // Step 3: Determine the variable payment
  // ======================================
  final variablePmtCalc = Calculator();
  variablePmtCalc.add(
    SeriesAdvance(
      label: 'Fixed period end balance',
      value: fixedPeriodBalance,
      postDateFrom: variablePeriodStart,
    ),
  );
  variablePmtCalc.add(
    SeriesPayment(
      numberOf: 300, // [60 months fixed, 300 variable]
      label: 'Variable payment',
      value: null, // Unknown variable payment (1489.19 @ 4.500017%)
      isInterestCapitalised: false,
      frequency: Frequency.monthly,
      postDateFrom: variablePaymentStart,
    ),
  );
  variablePmtCalc.add(
    SeriesPayment(
      numberOf: 100,
      label: 'Interest',
      value: 0.0,
      isInterestCapitalised: true,
      frequency: Frequency.quarterly,
      postDateFrom: rollMonth(variablePeriodStart, 3, variablePeriodStart.day),
    ),
  );
  final variablePmt = await variablePmtCalc.solveValue(
    dayCount: const US30360(),
    interestRate: variableRate,
  );

  // ===========================================
  // Step 4: Determine the overall implicit rate
  // ===========================================
  final implicitRateCalc = Calculator();
  implicitRateCalc.add(
    SeriesAdvance(
      label: 'Home mortgage loan',
      value: loanAmount,
      postDateFrom: contractStart,
    ),
  );
  implicitRateCalc.add(
    SeriesPayment(
      numberOf: 60, // [60 months fixed, 300 variable]
      label: 'Fixed payment',
      value: fixedPayment,
      isInterestCapitalised: false,
      frequency: Frequency.monthly,
      postDateFrom: fixedPaymentStart,
    ),
  );
  implicitRateCalc.add(
    SeriesPayment(
      numberOf: 300, // [60 months fixed, 300 variable]
      label: 'Variable payment',
      value: variablePmt,
      isInterestCapitalised: false,
      frequency: Frequency.monthly,
      postDateFrom: variablePaymentStart,
    ),
  );
  implicitRateCalc.add(
    SeriesPayment(
      numberOf: 120,
      label: 'Interest',
      value: 0.0,
      isInterestCapitalised: true,
      frequency: Frequency.quarterly,
      postDateFrom: rollMonth(
        contractStart,
        3,
        contractStart.day,
      ),
    ),
  );

  // Overall IRR = 4.052620% (3.25% for 60n, 4.50% for 300n)
  final rateImplicit = await implicitRateCalc.solveRate(
    dayCount: const US30360(),
  );

  print('Calculation completed in '
      '${DateTime.now().difference(startTime).inMilliseconds} milliseconds');

  // 5. Print results and amortisation schedule to console
  //
  // IMPORTANT: The current amortisation schedule implementation is designed
  // to amortise interest using the implict rate of the entire repayment
  // schedule. This is not the correct approach for this example. If required
  // you'll need to write your own implementation to correctly handle the
  // allocation of interest based on varying rates over time.
  //
  Schedule(
    profile: implicitRateCalc.profile!,
    rateResult: rateImplicit,
    valueResult: null,
  ).prettyPrint(example: 10);

  print('Calculation completed and rendered in '
      '${DateTime.now().difference(startTime).inMilliseconds} milliseconds');
}
