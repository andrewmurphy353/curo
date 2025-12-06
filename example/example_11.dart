import 'package:curo/curo.dart';

import 'schedule.dart';

/// Example 11: Solve an unknown instalment value in accordance with
/// US Appendix J.
///
/// An individual enters into a 3-year loan agreement for 15,000.00.
/// Repayments are due monthly in arrear. The APR is 6.0%.
///
/// Using the US Appendix J APR day count convention, compute the value
/// of the unknown instalment, and the implicit APR after rounding of the
/// result to 2 decimal places.
///
Future<void> main() async {
  // Step 1: Instantiate calculator
  final calculator = Calculator();

  // Step 2: Define the advance, payment, and/or charge series
  calculator.add(
    SeriesAdvance(
      label: 'Loan',
      value: 15000.0,
      postDateFrom: utcDate(DateTime(2026, 1, 10)),
    ),
  );
  calculator.add(
    SeriesPayment(
      numberOf: 36,
      label: 'Instalment',
      value: null, // leave undefined or null when it is the unknown to solve
      frequency: Frequency.monthly,
      postDateFrom: utcDate(DateTime(2026, 2, 15)),
    ),
  );
  calculator.add(
    SeriesCharge(
      label: 'Fee',
      value: 200.0,
      postDateFrom: utcDate(DateTime(2026, 1, 10)),
    ),
  );

  // 3. Calculate the unknown cash flow value
  final valueResult = await calculator.solveValue(
    dayCount: const USAppendixJ(),
    interestRate: 0.15,
  );

  // 4. Calculate the APR implicit in the cash flow profile
  //    now that the profile contains the computed cash flow
  //    values rounded to the required profile precision.
  final rateImplicit = await calculator.solveRate(
    dayCount: const USAppendixJ(),
  );

  // 5. Print results and amortisation schedule to console
  Schedule(
    profile: calculator.profile!,
    rateResult: rateImplicit,
    valueResult: valueResult,
  ).prettyPrint(example: 11);
}
