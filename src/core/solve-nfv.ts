import { Profile } from '../profile/profile';
import { SolveCallback } from './solve-root';

/**
 * Callback for solving interest rates.
 */
export class SolveNfv implements SolveCallback {
  private readonly profile: Profile;

  constructor(options: {
    profile: Profile;
  }) {
    this.profile = options.profile;
  }

  /**
   * Evaluates the net future value of cash flows at a given interest rate.
   * 
   * @param rate The interest rate to evaluate at
   * @returns The net future value
   */
  evaluate(rate: number): number {
    let nfv = 0;
    
    for (const flow of this.profile.cashFlows) {
      if (flow.periodFactor) {
        nfv += flow.value * Math.pow(1 + rate, 1 - flow.periodFactor.value);
      } else {
        nfv += flow.value;
      }
    }
    
    return nfv;
  }
}
