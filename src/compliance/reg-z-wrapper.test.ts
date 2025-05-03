import { RegZCalculator, FeeInclusionType } from './reg-z-wrapper';

describe('RegZCalculator', () => {
  let calculator: RegZCalculator;

  beforeEach(() => {
    calculator = new RegZCalculator(2);
  });

  it('should calculate APR with known interest rate', async () => {
    const result = await calculator.calculateAPR({
      principal: 10000,
      originationDate: new Date(Date.UTC(2022, 0, 1)),
      numberOfPayments: 12,
      paymentFrequencyMonths: 1,
      interestRate: 0.0825,
      fees: [
        {
          amount: 100,
          date: new Date(Date.UTC(2022, 0, 1)),
          description: 'Origination Fee',
          inclusionType: FeeInclusionType.FinanceCharge
        }
      ]
    });

    expect(result.apr).toBeCloseTo(0.0825, 4);
    expect(result.amountFinanced).toBe(10000);
    expect(result.financeCharge).toBeGreaterThan(100); // Should include interest
    expect(result.paymentAmount).toBeGreaterThan(0);
  });

  it('should calculate APR with known payment amount', async () => {
    const result = await calculator.calculateAPR({
      principal: 10000,
      originationDate: new Date(Date.UTC(2022, 0, 1)),
      numberOfPayments: 12,
      paymentFrequencyMonths: 1,
      paymentAmount: 879.16,
      fees: [
        {
          amount: 100,
          date: new Date(Date.UTC(2022, 0, 1)),
          description: 'Origination Fee',
          inclusionType: FeeInclusionType.FinanceCharge
        }
      ]
    });

    expect(result.apr).toBeGreaterThan(0);
    expect(result.amountFinanced).toBe(10000);
    expect(result.financeCharge).toBeGreaterThan(100); // Should include interest
    expect(result.paymentAmount).toBeCloseTo(879.16, 2);
  });

  it('should handle prepaid finance charges', async () => {
    const result = await calculator.calculateAPR({
      principal: 10000,
      originationDate: new Date(Date.UTC(2022, 0, 1)),
      numberOfPayments: 12,
      paymentFrequencyMonths: 1,
      interestRate: 0.0825,
      fees: [
        {
          amount: 500,
          date: new Date(Date.UTC(2022, 0, 1)),
          description: 'Prepaid Finance Charge',
          inclusionType: FeeInclusionType.PrepaidFinanceCharge
        }
      ]
    });

    expect(result.amountFinanced).toBe(9500); // Principal minus prepaid finance charge
    expect(result.financeCharge).toBeGreaterThan(500); // Should include interest
  });

  it('should handle odd days interest', async () => {
    const originationDate = new Date(Date.UTC(2022, 0, 15));
    const firstPaymentDate = new Date(Date.UTC(2022, 2, 1)); // March 1st
    
    const result = await calculator.calculateAPR({
      principal: 10000,
      originationDate,
      numberOfPayments: 12,
      paymentFrequencyMonths: 1,
      interestRate: 0.0825,
      firstPaymentDate,
      includeOddDaysInterest: true,
      fees: []
    });

    expect(result.apr).toBeCloseTo(0.0825, 4);
    expect(result.isWithinTolerance).toBe(true);
  });

  it('should determine if transaction is irregular', async () => {
    const originationDate = new Date(Date.UTC(2022, 0, 15));
    const firstPaymentDate = new Date(Date.UTC(2022, 2, 1)); // Irregular first payment
    
    const result = await calculator.calculateAPR({
      principal: 10000,
      originationDate,
      numberOfPayments: 12,
      paymentFrequencyMonths: 1,
      interestRate: 0.0825,
      firstPaymentDate,
      includeOddDaysInterest: true,
      fees: []
    });

    expect(result.isWithinTolerance).toBe(true);
  });
});
