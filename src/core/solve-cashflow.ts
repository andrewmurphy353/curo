import { Profile } from '../profile/profile';
import { SolveCallback } from './solve-root';

/**
 * Callback for solving cash flow values.
 */
export class SolveCashFlow implements SolveCallback {
  private readonly profile: Profile;
  private readonly effectiveRate: number;

  constructor(options: {
    profile: Profile;
    effectiveRate: number;
  }) {
    this.profile = options.profile;
    this.effectiveRate = options.effectiveRate;
  }

  /**
   * Evaluates the net present value of cash flows at a given value.
   * 
   * @param x The value to evaluate at
   * @returns The net present value
   */
  evaluate(x: number): number {
    let npv = 0;
    
    for (const flow of this.profile.cashFlows) {
      const value = flow.isKnown ? flow.value : x * flow.weighting;
      
      if (flow.periodFactor) {
        npv += value * Math.pow(1 + this.effectiveRate, -flow.periodFactor.value);
      } else {
        npv += value;
      }
    }
    
    return npv;
  }
}
