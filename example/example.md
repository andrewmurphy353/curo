# Curo Example: Solving for Monthly Instalment and Implicit Rate

This example shows how to:
- Solve for an unknown monthly instalment given a known interest rate
- Compute the implicit (effective) interest rate from a cash flow profile
- Generate and display a full amortisation schedule

```dart
import 'package:curo/curo.dart';

void main() async {
  // Create a calculator with 2 decimal places precision (default)
  final calculator = Calculator()
    ..add(
      SeriesAdvance(
        label: 'Loan',
        amount: 10000.0,
      ),
    )
    ..add(
      SeriesPayment(
        numberOf: 6,
        label: 'Instalment',
        amount: null, // Unknown — we will solve for this
        mode: Mode.arrear,
      ),
    );

  // Use the common US 30U/360 day count convention
  final convention = US30U360();

  // Solve for the unknown monthly instalment at 8.25% interest
  final payment = await calculator.solveValue(
    convention: convention,
    interestRate: 0.0825,
    startDate: DateTime.utc(2026, 1, 5),
  );

  // Solve for the implicit rate that makes NPV = 0 (should match 8.25%)
  final implicitRate = await calculator.solveRate(convention: convention);

  // Build and display the amortisation schedule using the implicit rate
  final schedule = calculator.buildSchedule(
    convention: convention,
    interestRate: implicitRate,
  );

  print('Monthly instalment: \$${payment.toStringAsFixed(2)}');
  print('Implicit interest rate: ${(implicitRate * 100).toStringAsFixed(2)}%\n');

  schedule.prettyPrint(convention: convention);
}
```

## Expected Output

```
Monthly instalment: $1707.00
Implicit interest rate: 8.25%

post_date    label                amount        capital       interest  capital_balance
---------------------------------------------------------------------------------------
2026-01-05   Loan             -10,000.00     -10,000.00           0.00       -10,000.00
2026-02-05   Instalment         1,707.00       1,638.25         -68.75        -8,361.75
2026-03-05   Instalment         1,707.00       1,649.51         -57.49        -6,712.24
2026-04-05   Instalment         1,707.00       1,660.85         -46.15        -5,051.39
2026-05-05   Instalment         1,707.00       1,672.27         -34.73        -3,379.12
2026-06-05   Instalment         1,707.00       1,683.77         -23.23        -1,695.35
2026-07-05   Instalment         1,707.00       1,695.35         -11.65             0.00
```

For more worked examples (including leasing, hire-purchase, fees, and regulatory APR calculations), visit the full documentation:
https://andrewmurphy353.github.io/curo/examples/overview/