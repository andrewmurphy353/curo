# Curo

A feature-rich library for performing simple to advanced instalment credit financial calculations.

Note: <i>This library is a port of the [curo-calculator](https://github.com/andrewmurphy353/curo-calculator) TypeScript repository and includes a small number of refactorings and some code reorganisation.</i>

## Overview

This financial calculator library is for solving unknown cash flow values and unknown interest rates implicit in fixed-term instalment credit products, for example leasing, loans and hire purchase contracts [^1], and incorporates features that are likely to be found only in commercially developed software. It has been designed for use in applications with requirements that extend beyond what can be achieved using standard financial algebra.

For an introduction to many of the features be sure to check out the GitHub repository [examples](https://github.com/andrewmurphy353/curo/tree/main/example) and the accompanying cash flow diagrams which pictorially represent the cash inflows and outflows [^2] of each example.

Using the calculator is straightforward as the following examples demonstrate. 

### Example using `solveValue(...)` to find an unknown cash flow value:

```dart
// Step 1: Instantiate the calculator
final calculator = Calculator();

// Step 2: Define the advance, payment, and/or charge cash flow series
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

// 3. Calculate the unknown cash flow value (result = 1706.93)
final valueResult = calculator.solveValue(
  dayCount: const US30360(),
  interestRate: 0.0825,
);
```
In step 2 we set the payment series value to `null`. This is how the unknown cash flow values that are to be computed are identified and is the protocol to be followed when defining the unknown cash flow values you wish to calculate.

In the final step we invoke the `solveValue(...)` method, passing in a day count convention instance and the annual interest rate to use in the calculation, expressed as a decimal. 

The various day count conventions available in this library are described in more detail below.

### Example using `solveRate(...)` to find the implicit interest rate in a cash flow series:

```dart
// Step 1: Instantiate the calculator
final calculator = Calculator();

// Step 2: Define the advance, payment, and/or charge cash flow series
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
    value: 1706.93,
    mode: Mode.arrear,
  ),
);

// 3. Calculate the IRR or Internal Rate of Return (result = 8.249121%)
final irrRate = calculator.solveRate(
    dayCount: const US30360(),
);
  // ...or the APR for regulated EU Consumer Credit agreements (result = 8.583131%)
final aprRate = calculator.solveRate(
    dayCount: const EU200848EC(),
);
```

### Day Count Conventions

A day count convention is a key component of every financial calculation as it determines the method to be used in measuring the time interval between each cash flow in a series.

There are dozens of convention's defined but the more important ones supported by this calculator are as follows:

Convention | Description
-----------| -------------
Actual ISDA | Convention accounts for actual days between cash flow dates based on the portion in a leap year and the portion in a non-leap year as [documented here](https://en.wikipedia.org/wiki/Day_count_convention#Actual/Actual_ISDA).
Actual/365 | Convention accounts for actual days between cash flow dates and considers a year to have 365 days as [documented here](https://en.wikipedia.org/wiki/Day_count_convention#Actual/365_Fixed).
EU 30/360 | Convention accounts for days between cash flow dates based on a 30 day month, 360 day year as [documented here](https://en.wikipedia.org/wiki/Day_count_convention#30E/360). 
EU 2008/48/EC | Convention based on the time periods between cash flow dates and the initial drawdown date, expressed in days and/or whole weeks, months or years. This convention is used specifically in APR (Annual Percentage Rate) consumer credit calculations within the European Union and is compliant with the EU2008/49/EC directive [available here](https://publications.europa.eu/en/publication-detail/-/publication/e4945793-f1f9-4527-8a2e-9060378fc302/language-en#).
US 30/360 | Convention accounts for days between cash flow dates based on a 30 day month, 360 day year as  [documented here](https://en.wikipedia.org/wiki/Day_count_convention#30/360_US). This is the default convention used by the Hewlett Packard HP12C and similar financial calculators, so choose this convention when unsure as it is the defacto convention used in the majority of fixed-term credit calculations.

All conventions, except EU 2008/48/EC, will by default compute time intervals between cash flows with reference to the dates of adjacent cash flows.

To override this so that time intervals are computed with reference to the first drawdown date, as in XIRR (eXtended Internal Rate of Return) based calculations, simply pass `useXirrMethod: true` to the respective day count convention constructor (refer to the code documentation for details). 

When the Actual/365 convention is used in this manner, e.g. `Act365(useXirrMethod: true)` the XIRR result will equal that produced by the equivalent Microsoft Excel XIRR function.

## Installation

With Dart
```shell
$ dart pub add curo
```
With Flutter
```shell
$ flutter pub add curo
```

## License

Copyright © 2022, [Andrew Murphy](https://github.com/andrewmurphy353).
Released under the [MIT License](LICENSE).

### Footnotes
---

[^1] Whilst the library uses asset finance nomenclature, it is equally capable of solving problems in investment-type scenarios.

[^2] A cash flow diagram is simply a pictorial representation of the timing and direction of financial transactions.

The diagram begins with a horizontal line, called a time line. The line represents the duration or contract term, and is commonly divided into compounding periods. The exchange of money in the financial arrangement is depicted by vertical arrows. Money a lender receives is represented by an arrow pointing up from the point in the time line when the transaction occurs; money paid out by the lender is represented by an arrow pointing down. The collection of all up and down arrow cash flows are what is referred to throughout the calculator documentation as a cash flow series.

To illustrate using the example above, that is a 10,000.00 loan repayable by 6 monthly instalments in arrears (due at the end of each compounding period), the cash flow diagram would resemble something like this:

![image](assets/images/cash_flow_diagram_01.png)
