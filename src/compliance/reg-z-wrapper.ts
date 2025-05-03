/**
 * Regulation Z (TILA) compliance wrapper for Curo calculator
 * 
 * This module provides functions to ensure compliance with Regulation Z
 * of the Truth in Lending Act (TILA) when calculating APRs and other
 * financial disclosures.
 */

import { Calculator } from '../core/calculator';
import { Convention } from '../daycount/convention';
import { US30360 } from '../daycount/us-30-360';
import { CashFlow } from '../profile/cash-flow';
import { CashFlowAdvance } from '../profile/cash-flow-advance';
import { CashFlowCharge } from '../profile/cash-flow-charge';
import { CashFlowPayment } from '../profile/cash-flow-payment';
import { ProfileImpl } from '../profile/profile';
import { gaussRound } from '../utilities/math';

/**
 * Fee inclusion types for Regulation Z APR calculations
 */
export enum FeeInclusionType {
  /** Included in finance charge and APR */
  FinanceCharge = 'financeCharge',
  /** Excluded from finance charge and APR */
  Excluded = 'excluded',
  /** Prepaid finance charge (affects amount financed) */
  PrepaidFinanceCharge = 'prepaidFinanceCharge'
}

/**
 * Fee structure for Regulation Z calculations
 */
export interface RegZFee {
  /** Fee amount */
  amount: number;
  /** Date when fee is assessed */
  date: Date;
  /** Fee description */
  description: string;
  /** How this fee should be treated under Reg Z */
  inclusionType: FeeInclusionType;
}

/**
 * Loan parameters for Regulation Z calculations
 */
export interface RegZLoanParams {
  /** Principal loan amount */
  principal: number;
  /** Loan origination date */
  originationDate: Date;
  /** Number of payments */
  numberOfPayments: number;
  /** Payment frequency in months */
  paymentFrequencyMonths: number;
  /** Payment amount (if known, otherwise calculated) */
  paymentAmount?: number;
  /** Interest rate (if known, otherwise calculated) */
  interestRate?: number;
  /** Additional fees */
  fees: RegZFee[];
  /** First payment date (if different from standard schedule) */
  firstPaymentDate?: Date;
  /** Whether to include odd days interest */
  includeOddDaysInterest?: boolean;
}

/**
 * Result of Regulation Z APR calculation
 */
export interface RegZResult {
  /** Annual Percentage Rate */
  apr: number;
  /** Whether APR is within tolerance for disclosure */
  isWithinTolerance: boolean;
  /** Amount financed (principal minus prepaid finance charges) */
  amountFinanced: number;
  /** Total finance charge */
  financeCharge: number;
  /** Total of payments */
  totalOfPayments: number;
  /** Payment amount */
  paymentAmount: number;
  /** Cash flows used in calculation */
  cashFlows: CashFlow[];
  /** Whether loan is classified as HOEPA high-cost */
  isHighCostHOEPA?: boolean;
  /** Whether loan is classified as Higher-Priced Mortgage Loan */
  isHPML?: boolean;
}

/**
 * Regulation Z APR tolerance levels
 */
const REG_Z_TOLERANCES = {
  /** Regular transactions (±0.125%) */
  REGULAR: 0.00125,
  /** Irregular transactions (±0.25%) */
  IRREGULAR: 0.0025
};

/**
 * RegZ Calculator provides Regulation Z compliant financial calculations
 * by wrapping the core Curo calculator with additional compliance logic.
 */
export class RegZCalculator {
  private calculator: Calculator;
  private dayCount: Convention;
  
  /**
   * Creates a new RegZ calculator instance
   * 
   * @param precision Number of decimal places for calculations (0-4)
   */
  constructor(precision: number = 2) {
    this.calculator = new Calculator({ precision });
    this.dayCount = new US30360();
  }
  
  /**
   * Calculates the APR and related disclosures for a loan according to Regulation Z
   * 
   * @param params Loan parameters
   * @returns Regulation Z calculation results
   */
  async calculateAPR(params: RegZLoanParams): Promise<RegZResult> {
    const cashFlows = this.buildRegZCashFlows(params);
    
    const profile = new ProfileImpl({
      cashFlows,
      dayCount: this.dayCount,
      precision: this.calculator.precision
    });
    
    const regZCalculator = new Calculator({ 
      profile,
      precision: this.calculator.precision
    });
    
    let paymentAmount = params.paymentAmount;
    let interestRate = params.interestRate;
    
    if (!paymentAmount && interestRate) {
      paymentAmount = await regZCalculator.solveValue({
        dayCount: this.dayCount,
        interestRate
      });
    } else if (!interestRate && paymentAmount) {
      interestRate = await regZCalculator.solveRate({
        dayCount: this.dayCount
      });
    } else {
      throw new Error('Either payment amount or interest rate must be provided, but not both');
    }
    
    const prepaidFinanceCharges = params.fees
      .filter(fee => fee.inclusionType === FeeInclusionType.PrepaidFinanceCharge)
      .reduce((sum, fee) => sum + fee.amount, 0);
    
    const amountFinanced = params.principal - prepaidFinanceCharges;
    
    const financeCharges = params.fees
      .filter(fee => 
        fee.inclusionType === FeeInclusionType.FinanceCharge || 
        fee.inclusionType === FeeInclusionType.PrepaidFinanceCharge
      )
      .reduce((sum, fee) => sum + fee.amount, 0);
    
    const totalInterest = (paymentAmount! * params.numberOfPayments) - amountFinanced;
    
    const totalFinanceCharge = financeCharges + totalInterest;
    
    const totalOfPayments = amountFinanced + totalFinanceCharge;
    
    const isIrregular = this.isIrregularTransaction(params);
    const tolerance = isIrregular ? 
      REG_Z_TOLERANCES.IRREGULAR : 
      REG_Z_TOLERANCES.REGULAR;
    
    const disclosureAPR = this.roundAPRForDisclosure(interestRate!);
    const isWithinTolerance = Math.abs(disclosureAPR - interestRate!) <= tolerance;
    
    
    return {
      apr: interestRate!,
      isWithinTolerance,
      amountFinanced,
      financeCharge: totalFinanceCharge,
      totalOfPayments,
      paymentAmount: paymentAmount!,
      cashFlows
    };
  }
  
  /**
   * Builds cash flows according to Regulation Z rules
   * 
   * @param params Loan parameters
   * @returns Array of cash flows
   */
  private buildRegZCashFlows(params: RegZLoanParams): CashFlow[] {
    const cashFlows: CashFlow[] = [];
    
    cashFlows.push(new CashFlowAdvance({
      postDate: params.originationDate,
      value: params.principal,
      label: 'Principal'
    }));
    
    for (const fee of params.fees) {
      if (fee.inclusionType === FeeInclusionType.Excluded) {
        continue;
      }
      
      if (fee.inclusionType === FeeInclusionType.PrepaidFinanceCharge) {
        cashFlows.push(new CashFlowCharge({
          postDate: fee.date,
          value: fee.amount,
          label: fee.description
        }));
      } else if (fee.inclusionType === FeeInclusionType.FinanceCharge) {
        cashFlows.push(new CashFlowCharge({
          postDate: fee.date,
          value: fee.amount,
          label: fee.description
        }));
      }
    }
    
    const paymentDates = this.calculatePaymentDates(
      params.originationDate,
      params.numberOfPayments,
      params.paymentFrequencyMonths,
      params.firstPaymentDate
    );
    
    for (let i = 0; i < params.numberOfPayments; i++) {
      cashFlows.push(new CashFlowPayment({
        postDate: paymentDates[i],
        value: params.paymentAmount,
        isKnown: params.paymentAmount !== undefined,
        label: `Payment ${i + 1}`
      }));
    }
    
    if (params.includeOddDaysInterest && params.firstPaymentDate) {
      const oddDaysInterest = this.calculateOddDaysInterest(
        params.originationDate,
        params.firstPaymentDate,
        params.principal,
        params.interestRate || 0
      );
      
      if (oddDaysInterest > 0) {
        cashFlows.push(new CashFlowCharge({
          postDate: params.firstPaymentDate,
          value: oddDaysInterest,
          label: 'Odd Days Interest'
        }));
      }
    }
    
    return cashFlows.sort((a, b) => a.postDate.getTime() - b.postDate.getTime());
  }
  
  /**
   * Calculates payment dates based on loan parameters
   * 
   * @param originationDate Loan origination date
   * @param numberOfPayments Number of payments
   * @param frequencyMonths Payment frequency in months
   * @param firstPaymentDate Optional custom first payment date
   * @returns Array of payment dates
   */
  private calculatePaymentDates(
    originationDate: Date,
    numberOfPayments: number,
    frequencyMonths: number,
    firstPaymentDate?: Date
  ): Date[] {
    const dates: Date[] = [];
    
    let currentDate = firstPaymentDate ? 
      new Date(firstPaymentDate) : 
      this.addMonths(originationDate, frequencyMonths);
    
    dates.push(new Date(currentDate));
    
    for (let i = 1; i < numberOfPayments; i++) {
      currentDate = this.addMonths(currentDate, frequencyMonths);
      dates.push(new Date(currentDate));
    }
    
    return dates;
  }
  
  /**
   * Adds months to a date, adjusting for month end dates
   * 
   * @param date Base date
   * @param months Number of months to add
   * @returns New date with months added
   */
  private addMonths(date: Date, months: number): Date {
    const result = new Date(date);
    const currentMonth = result.getMonth();
    const targetMonth = currentMonth + months;
    
    result.setMonth(targetMonth);
    
    if (result.getMonth() !== (targetMonth % 12)) {
      result.setDate(0);
    }
    
    return result;
  }
  
  /**
   * Calculates odd days interest for irregular first periods
   * 
   * @param originationDate Loan origination date
   * @param firstPaymentDate First payment date
   * @param principal Loan principal
   * @param rate Annual interest rate as decimal
   * @returns Odd days interest amount
   */
  private calculateOddDaysInterest(
    originationDate: Date,
    firstPaymentDate: Date,
    principal: number,
    rate: number
  ): number {
    const factor = this.dayCount.computeFactor(originationDate, firstPaymentDate);
    
    const interest = principal * rate * factor.value;
    
    return gaussRound(interest, this.calculator.precision);
  }
  
  /**
   * Determines if a transaction is "irregular" under Regulation Z
   * Irregular transactions have higher APR disclosure tolerances
   * 
   * @param params Loan parameters
   * @returns Whether the transaction is irregular
   */
  private isIrregularTransaction(params: RegZLoanParams): boolean {
    
    
    if (params.includeOddDaysInterest) {
      return true;
    }
    
    if (params.firstPaymentDate) {
      const standardFirstPayment = this.addMonths(
        params.originationDate, 
        params.paymentFrequencyMonths
      );
      
      const standardDay = standardFirstPayment.getDate();
      const actualDay = params.firstPaymentDate.getDate();
      
      if (Math.abs(standardDay - actualDay) > 1) {
        return true;
      }
    }
    
    return false;
  }
  
  /**
   * Rounds APR for disclosure purposes according to Regulation Z
   * APR should be disclosed to the nearest 1/8th of 1 percent (0.125%)
   * 
   * @param apr Calculated APR as decimal
   * @returns APR rounded for disclosure
   */
  private roundAPRForDisclosure(apr: number): number {
    const percentage = apr * 100;
    
    const roundedPercentage = Math.round(percentage / 0.125) * 0.125;
    
    return roundedPercentage / 100;
  }
}
