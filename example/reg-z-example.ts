import { 
  RegZCalculator, 
  FeeInclusionType, 
  RegZLoanParams 
} from '../src';

/**
 * Example: Using the RegZCalculator for Regulation Z compliant APR calculations
 * 
 * This example demonstrates how to use the RegZCalculator to calculate APR
 * and other disclosures in compliance with Regulation Z (TILA).
 */
async function main() {
  const regZCalculator = new RegZCalculator(2);
  
  const loanParams: RegZLoanParams = {
    principal: 10000.00,
    originationDate: new Date(2022, 0, 15), // January 15, 2022
    numberOfPayments: 12,
    paymentFrequencyMonths: 1,
    interestRate: 0.0825, // 8.25%
    fees: [
      {
        amount: 100.00,
        date: new Date(2022, 0, 15),
        description: 'Origination Fee',
        inclusionType: FeeInclusionType.FinanceCharge
      },
      {
        amount: 50.00,
        date: new Date(2022, 0, 15),
        description: 'Application Fee',
        inclusionType: FeeInclusionType.PrepaidFinanceCharge
      },
      {
        amount: 25.00,
        date: new Date(2022, 0, 15),
        description: 'Credit Report Fee',
        inclusionType: FeeInclusionType.Excluded
      }
    ],
    firstPaymentDate: new Date(2022, 2, 1), // March 1, 2022
    includeOddDaysInterest: true
  };
  
  const result = await regZCalculator.calculateAPR(loanParams);
  
  console.log('Regulation Z Disclosures:');
  console.log('------------------------');
  console.log(`APR: ${(result.apr * 100).toFixed(3)}%`);
  console.log(`APR for disclosure: ${(Math.round(result.apr * 100 / 0.125) * 0.125).toFixed(3)}%`);
  console.log(`Within tolerance: ${result.isWithinTolerance ? 'Yes' : 'No'}`);
  console.log(`Amount financed: $${result.amountFinanced.toFixed(2)}`);
  console.log(`Finance charge: $${result.financeCharge.toFixed(2)}`);
  console.log(`Total of payments: $${result.totalOfPayments.toFixed(2)}`);
  console.log(`Payment amount: $${result.paymentAmount.toFixed(2)}`);
  
  const paymentParams: RegZLoanParams = {
    ...loanParams,
    interestRate: undefined,
    paymentAmount: 879.16
  };
  
  const paymentResult = await regZCalculator.calculateAPR(paymentParams);
  
  console.log('\nCalculating Interest Rate from Payment:');
  console.log('------------------------------------');
  console.log(`Interest Rate: ${(paymentResult.apr * 100).toFixed(3)}%`);
}

main().catch(console.error);
