import { CashFlowBase } from './cash-flow';
import { DayCountFactor } from '../daycount/day-count-factor';

/**
 * Represents an advance cash flow (typically money lent/borrowed).
 */
export class CashFlowAdvance extends CashFlowBase {
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
      label: options.label ?? 'Advance',
      periodFactor: options.periodFactor
    });
  }
}
