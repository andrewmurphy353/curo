# Curo TypeScript

![Build Status](https://github.com/bnovarini/curo-ts/actions/workflows/typescript-ci.yml/badge.svg)
![GitHub](https://img.shields.io/github/license/bnovarini/curo-ts.svg)

A comprehensive TypeScript library designed for performing both simple and complex instalment credit financial calculations.

## Overview

This financial calculator library is for solving unknown cash flow values and unknown interest rates implicit in fixed-term instalment credit products, for example leasing, loans and hire purchase contracts [^1], and incorporates features that are likely to be found only in commercially developed software. It has been designed for use in applications with requirements that extend beyond what can be achieved using standard financial algebra.

Using the calculator is straightforward as the following examples demonstrate.

### Example using `solveValue(...)` to find an unknown cash flow value:

```typescript
import { Calculator, SeriesAdvance, SeriesPayment, Mode, US30360 } from 'curo-ts';

// Step 1: Instantiate the calculator
const calculator = new Calculator();

// Step 2: Define the advance, payment, and/or charge cash flow series
calculator.add(
  new SeriesAdvance({
    label: 'Loan',
    value: 10000.0,
  })
);
calculator.add(
  new SeriesPayment({
    numberOf: 6,
    label: 'Instalment',
    value: null, // leave undefined or null when it is the unknown to solve
    mode: Mode.Arrear,
  })
);

// 3. Calculate the unknown cash flow value (result = 1707.00 to 2 decimal places)
const valueResult = await calculator.solveValue({
  dayCount: new US30360(),
  interestRate: 0.0825,
});
```
In the 2nd step we set the payment series value to `null`. We could also simply omit the value attribute. This is how the unknown cash flow values that are to be computed are identified, and is the protocol to be followed when defining the unknown cash flow values you wish to calculate.

In the 3rd and final step we invoke the `solveValue(...)` method, passing in a day count convention instance and the annual interest rate to use in the calculation, expressed as a decimal.

The various day count conventions available in this library are described in more detail below.

### Example using `solveRate(...)` to find the implicit interest rate in a cash flow series:

```typescript
import { Calculator, SeriesAdvance, SeriesPayment, Mode, US30360 } from 'curo-ts';

// Step 1: Instantiate the calculator
const calculator = new Calculator();

// Step 2: Define the advance, payment, and/or charge cash flow series
calculator.add(
  new SeriesAdvance({
    label: 'Loan',
    value: 10000.0,
  })
);
calculator.add(
  new SeriesPayment({
    numberOf: 6,
    label: 'Instalment',
    value: 1707.00,
    mode: Mode.Arrear,
  })
);

// 3. Calculate the IRR or Internal Rate of Return (result = 8.250040%)
const irrRate = await calculator.solveRate({
  dayCount: new US30360(),
});
```

## Installation

```shell
$ npm install curo-ts
```

## License

Released under the [MIT License](LICENSE).

### Footnotes
---

[^1] Whilst the library uses asset finance nomenclature, it is equally capable of solving problems in investment-type scenarios.
