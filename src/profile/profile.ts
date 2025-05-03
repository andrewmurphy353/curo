import { CashFlow } from './cash-flow';
import { Convention } from '../daycount/convention';

/**
 * Represents a collection of cash flows with calculation settings.
 */
export interface Profile {
  /** Collection of cash flows */
  cashFlows: CashFlow[];
  
  /** Day count convention */
  dayCount?: Convention;
  
  /** Number of decimal places for rounding */
  precision: number;
}

/**
 * Implementation of the Profile interface
 */
export class ProfileImpl implements Profile {
  readonly cashFlows: CashFlow[];
  readonly dayCount?: Convention;
  readonly precision: number;

  constructor(options: {
    cashFlows: CashFlow[];
    dayCount?: Convention;
    precision?: number;
  }) {
    this.cashFlows = [...options.cashFlows];
    this.dayCount = options.dayCount;
    this.precision = options.precision ?? 2;
    
    if (this.precision < 0 || this.precision > 4) {
      throw new Error('Precision must be between 0 and 4 inclusive');
    }
  }

  /**
   * Creates a copy of this profile with optional overrides
   */
  copyWith(options: {
    cashFlows?: CashFlow[];
    dayCount?: Convention;
    precision?: number;
  }): ProfileImpl {
    return new ProfileImpl({
      cashFlows: options.cashFlows ?? this.cashFlows,
      dayCount: options.dayCount ?? this.dayCount,
      precision: options.precision ?? this.precision
    });
  }
}
