import { DayCountFactor } from '../daycount/day-count-factor';

/**
 * Common interface for all cash flow types
 */
export interface CashFlow {
  /** The due date of the cash flow value */
  postDate: Date;
  
  /** The settlement date of the cash flow value */
  valueDate: Date;
  
  /** The positive or negative cash flow value */
  value: number;
  
  /** Flag indicating if the cash flow value is known or to be computed */
  isKnown: boolean;
  
  /** 
   * Weighting determines the scale of an unknown cash flow value 
   * relative to other unknown cash flows
   */
  weighting: number;
  
  /** Description of the cash flow */
  label: string;
  
  /** The time factor for this period */
  periodFactor?: DayCountFactor;
}

/**
 * Base implementation for cash flow types
 */
export abstract class CashFlowBase implements CashFlow {
  readonly postDate: Date;
  readonly valueDate: Date;
  readonly value: number;
  readonly isKnown: boolean;
  readonly weighting: number;
  readonly label: string;
  readonly periodFactor?: DayCountFactor;

  constructor(options: {
    postDate: Date;
    valueDate: Date;
    value: number;
    isKnown: boolean;
    weighting?: number;
    label?: string;
    periodFactor?: DayCountFactor;
  }) {
    if (!options.postDate.getTime || !options.valueDate.getTime) {
      throw new Error('The cash flow dates must be valid Date objects');
    }
    
    if (options.valueDate.getTime() < options.postDate.getTime()) {
      throw new Error('The cash flow value date must fall on or after the post date');
    }
    
    if (options.weighting !== undefined && !(options.weighting > 0)) {
      throw new Error('The cash flow weighting value must be greater than 0.0');
    }

    this.postDate = options.postDate;
    this.valueDate = options.valueDate;
    this.value = options.value;
    this.isKnown = options.isKnown;
    this.weighting = options.weighting ?? 1.0;
    this.label = options.label ?? '';
    this.periodFactor = options.periodFactor;
  }
}
