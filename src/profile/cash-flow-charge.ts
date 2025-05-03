import { CashFlowBase } from './cash-flow';
import { DayCountFactor } from '../daycount/day-count-factor';

/**
 * Represents a charge cash flow (typically fees or other charges).
 */
export class CashFlowCharge extends CashFlowBase {
  constructor(options: {
    postDate: Date;
    valueDate?: Date;
    value?: number;
    isKnown?: boolean;
    weighting?: number;
    label?: string;
    periodFactor?: DayCountFactor;
  }) {
    super({
      postDate: options.postDate,
      valueDate: options.valueDate ?? options.postDate,
      value: options.value ?? 0,
      isKnown: options.isKnown ?? (options.value !== undefined && options.value !== null),
      weighting: options.weighting,
      label: options.label ?? 'Charge',
      periodFactor: options.periodFactor
    });
  }
}
