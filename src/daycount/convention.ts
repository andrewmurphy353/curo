import { DayCountFactor } from './day-count-factor';
import { DayCountOrigin } from './day-count-origin';

/**
 * Options for all day count conventions
 */
export interface ConventionOptions {
  /** Whether to use post dates or value dates for calculations */
  usePostDates?: boolean;
  /** Whether to include non-financing flows in calculations */
  includeNonFinancingFlows?: boolean;
  /** Whether to use XIRR method for time period calculations */
  useXirrMethod?: boolean;
}

/**
 * Base class for all day count conventions.
 */
export abstract class Convention {
  readonly usePostDates: boolean;
  readonly includeNonFinancingFlows: boolean;
  readonly useXirrMethod: boolean;

  constructor(options: ConventionOptions = {}) {
    this.usePostDates = options.usePostDates !== undefined ? options.usePostDates : true;
    this.includeNonFinancingFlows = options.includeNonFinancingFlows !== undefined ? options.includeNonFinancingFlows : false;
    this.useXirrMethod = options.useXirrMethod !== undefined ? options.useXirrMethod : false;
  }

  /**
   * Returns the origin method for day count calculations
   */
  dayCountOrigin(): DayCountOrigin {
    if (this.useXirrMethod) {
      return DayCountOrigin.Drawdown;
    }
    return DayCountOrigin.Neighbor;
  }

  /**
   * Computes the periodic factor for a given day count convention.
   * 
   * @param d1 - the earlier of two dates
   * @param d2 - the later of two dates
   */
  abstract computeFactor(d1: Date, d2: Date): DayCountFactor;
}
