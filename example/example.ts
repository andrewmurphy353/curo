import { Calculator, SeriesAdvance, SeriesPayment, Mode, US30360 } from '../src';

/**
 * Example 1: Solve Unknown Payment, Compute Borrower's IRR (effective rate)
 *
 * An individual has applied for a loan of 10,000.00, repayable by 6 monthly
 * instalments in arrears. The lender's effective annual interest rate
 * is 8.25%.
 *
 * Using the US 30/360 day count convention, compute the value of the
 * unknown instalments.
 */
async function main() {
  const calculator = new Calculator();

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

  const valueResult = await calculator.solveValue({
    dayCount: new US30360(),
    interestRate: 0.0825,
  });

  const rateImplicit = await calculator.solveRate({
    dayCount: new US30360(),
  });

  console.log(`Payment value: ${valueResult.toFixed(2)}`);
  console.log(`Implicit rate: ${(rateImplicit * 100).toFixed(6)}%`);
}

main().catch(console.error);
