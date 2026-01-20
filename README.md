# Curo Dart

![Dart CI](https://github.com/andrewmurphy353/curo/actions/workflows/dart_ci.yml/badge.svg)
[![codecov](https://codecov.io/gh/andrewmurphy353/curo/branch/main/graph/badge.svg?token=YOLLETTV0K)](https://codecov.io/gh/andrewmurphy353/curo)
[![Pub Package](https://img.shields.io/pub/v/curo.svg)](https://pub.dev/packages/curo)
![GitHub License](https://img.shields.io/github/license/andrewmurphy353/curo)

**Curo** is a powerful, modern Dart library for performing instalment credit financial calculations - from simple loans to complex leasing and hire-purchase agreements.

This is a **complete ground-up rewrite** (version 3.0.0+) of the original `curo` package, now aligned with the latest Dart conventions and fully compatible in design and accuracy with its sister project, [`curo-python`](https://github.com/andrewmurphy353/curo_python).

Explore the [documentation](https://pub.dev/documentation/curo/latest/), try it live in the **[Curo Calculator](https://curocalc.app)** app (built with this library), or browse the [examples](https://github.com/andrewmurphy353/curo/examples/overview).

## Why Curo?

Curo goes beyond basic financial functions, offering features typically found only in commercial software:

- Solve for unknown payment/instalment amounts (`solveValue`)
- Compute implicit effective rates or regulatory APRs (`solveRate`)
- Support for multiple global day count conventions (US, EU, UK)
- Precise amortisation schedules and APR proof tables
- Weighted unknowns, charges, capitalised interest, and flexible series

Perfect for loan pricing, regulatory compliance (e.g., EU CCD, UK CONC, US Reg Z), leasing, or investment analysis.

## Getting Started

### Installation

Add Curo to your project:

```shell
dart pub add curo
# or
flutter pub add curo
```

### Basic Usage

#### **Example: Solving for a monthly instalment**

```dart
import 'package:curo/curo.dart';

void main() async {
  final calculator = Calculator(precision: 2)
    ..add(SeriesAdvance(amount: 10000.0, label: 'Loan'))
    ..add(SeriesPayment(numberOf:6, amount: null, label: 'Instalment'));
  final convention = const US30U360();

  final value = await calculator.solveValue(
    convention: convention,
    interestRate: 0.12);                      // => 1708.4

  final rate = await calculator.solveRate(
    convention: convention);                  // => 0.12000094629126792

  final schedule = calculator.buildSchedule(convention: convention, interestRate: rate);
  schedule.prettyPrint(convention: convention);
}
```
Output:

```shell
post_date    label                amount        capital       interest  capital_balance
---------------------------------------------------------------------------------------
2026-01-15   Loan             -10,000.00     -10,000.00           0.00       -10,000.00
2026-01-15   Instalment         1,708.40       1,708.40           0.00        -8,291.60
2026-02-15   Instalment         1,708.40       1,625.48         -82.92        -6,666.12
2026-03-15   Instalment         1,708.40       1,641.74         -66.66        -5,024.38
2026-04-15   Instalment         1,708.40       1,658.16         -50.24        -3,366.22
2026-05-15   Instalment         1,708.40       1,674.74         -33.66        -1,691.48
2026-06-15   Instalment         1,708.40       1,691.48         -16.92             0.00
```

#### **Example: Solving for the implicit rate (IRR or APR)**

```dart
import 'package:curo/curo.dart';

void main() async {
  final calculator = Calculator(precision: 2)
    ..add(SeriesAdvance(amount: 10000.0, label: 'Loan'))
    ..add(SeriesPayment(numberOf: 6, amount: 1708.40, label: 'Instalment'));

  final irr = await calculator.solveRate(convention: const US30U360());
  // => 0.1200009462912679 ~ 0.12 or 12.0% (matches the input rate within precision)

  final apr = await calculator.solveRate(convention: EU200848EC());
  // => 0.1268260858796374 ~ 0.127 or 12.7% (regulatory APR under EU rules)
}
```

## Key Features

### Day Count Conventions

Day count conventions determine how time intervals between cash flows are measured. Curo supports a wide range of conventions to meet global financial standards:

Convention|Description
:---------|:----------
Actual ISDA | Uses actual days, accounting for leap and non-leap year portions.
Actual/360 | Counts actual days, assuming a 360-day year.
Actual/365 | Counts actual days, assuming a 365-day year.
EU 30/360 | Assumes 30-day months and a 360-day year, per EU standards.
EU 2023/2225 | Compliant with EU Directive 2023/2225 for APR calculations in consumer credit.
UK CONC App | Supports UK APRC calculations for consumer credit, secured or unsecured.
US 30/360 | Default for many US calculations, using 30-day months and a 360-day year.
US 30U/360 | Like US 30/360, but treats February days uniformly as 30 days.
US Appendix J | Implements US Regulation Z, Appendix J for APR in closed-end credit.

Most conventions default to period-by-period timing. For XIRR-style calculations (time from first advance), pass `useXirrMethod: true` in the constructor. `Actual365(useXirrMethod: true)` matches Excel’s `XIRR()` exactly.

### Cash Flow Diagrams

Cash flow diagrams visually represent the timing and direction of financial transactions. For example, a €10,000 loan repaid in 6 monthly instalments would look like this:

![Cash Flow Diagram](https://github.com/andrewmurphy353/curo/blob/main/doc/site/assets/images/example-01.png)

- **Down arrows**: Money received (e.g., loan advance).
- **Up arrows**: Money paid (e.g., instalments).
- **Time line**: Represents the contract term, divided into compounding periods.

## License

Copyright © 2026, [Andrew Murphy](https://github.com/andrewmurphy353).
Released under the [MIT License](LICENSE).

## Learn More

- **Examples**: Dive into practical use cases in the documentation [examples](https://andrewmurphy353.github.io/curo/examples/overview/).
- **Documentation**: Refer to the code [documentation](https://andrewmurphy353.github.io/curo/api/) for detailed class and method descriptions.
- **Issues & Contributions**: Report bugs or contribute on [GitHub](https://github.com/andrewmurphy353/curo/issues).

