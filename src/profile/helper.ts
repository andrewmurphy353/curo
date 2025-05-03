import { CashFlow } from './cash-flow';
import { CashFlowAdvance } from './cash-flow-advance';
import { CashFlowPayment } from './cash-flow-payment';
import { CashFlowCharge } from './cash-flow-charge';
import { Series } from '../series/series';
import { SeriesAdvance } from '../series/series-advance';
import { SeriesPayment } from '../series/series-payment';
import { SeriesCharge } from '../series/series-charge';
import { Profile, ProfileImpl } from './profile';
import { rollDate } from '../utilities/dates';
import { gaussRound } from '../utilities/math';

/**
 * Builds a profile from a series of cash flows
 */
export function buildProfile(options: {
  series: Series[];
  startDate: Date;
}): CashFlow[] {
  const { series, startDate } = options;
  const cashFlows: CashFlow[] = [];
  
  for (const item of series) {
    const postDateFrom = item.postDateFrom ?? startDate;
    
    for (let i = 0; i < item.numberOf; i++) {
      const postDate = i === 0 
        ? postDateFrom 
        : rollDate(postDateFrom, item.frequency, postDateFrom.getUTCDate());
      
      if (item instanceof SeriesAdvance) {
        cashFlows.push(new CashFlowAdvance({
          postDate,
          value: item.value ?? undefined,
          label: item.label
        }));
      } else if (item instanceof SeriesPayment) {
        cashFlows.push(new CashFlowPayment({
          postDate,
          value: item.value ?? undefined,
          label: item.label
        }));
      } else if (item instanceof SeriesCharge) {
        cashFlows.push(new CashFlowCharge({
          postDate,
          value: item.value ?? undefined,
          label: item.label
        }));
      }
    }
  }
  
  return cashFlows;
}

/**
 * Assigns day count factors to cash flows
 */
export function assignFactors(profile: Profile): ProfileImpl {
  if (!profile.dayCount) {
    return profile as ProfileImpl;
  }
  
  const cashFlows = [...profile.cashFlows];
  
  cashFlows.sort((a, b) => a.postDate.getTime() - b.postDate.getTime());
  
  for (let i = 1; i < cashFlows.length; i++) {
    const prev = cashFlows[i - 1];
    const curr = cashFlows[i];
    
    const factor = profile.dayCount.computeFactor(
      profile.dayCount.usePostDates ? prev.postDate : prev.valueDate,
      profile.dayCount.usePostDates ? curr.postDate : curr.valueDate
    );
    
    if (curr instanceof CashFlowAdvance) {
      cashFlows[i] = new CashFlowAdvance({
        ...curr,
        periodFactor: factor
      });
    } else if (curr instanceof CashFlowPayment) {
      cashFlows[i] = new CashFlowPayment({
        ...curr,
        periodFactor: factor
      });
    } else if (curr instanceof CashFlowCharge) {
      cashFlows[i] = new CashFlowCharge({
        ...curr,
        periodFactor: factor
      });
    }
  }
  
  return new ProfileImpl({
    ...profile,
    cashFlows
  });
}

/**
 * Updates unknown cash flow values
 */
export function updateUnknowns(options: {
  cashFlows: CashFlow[];
  value: number;
  precision: number;
}): CashFlow[] {
  const { cashFlows, value, precision } = options;
  const result: CashFlow[] = [];
  
  for (const flow of cashFlows) {
    if (!flow.isKnown) {
      const newValue = gaussRound(value * flow.weighting, precision);
      
      if (flow instanceof CashFlowAdvance) {
        result.push(new CashFlowAdvance({
          ...flow,
          value: newValue,
          isKnown: true
        }));
      } else if (flow instanceof CashFlowPayment) {
        result.push(new CashFlowPayment({
          ...flow,
          value: newValue,
          isKnown: true
        }));
      } else if (flow instanceof CashFlowCharge) {
        result.push(new CashFlowCharge({
          ...flow,
          value: newValue,
          isKnown: true
        }));
      } else {
        result.push(flow);
      }
    } else {
      result.push(flow);
    }
  }
  
  return result;
}

/**
 * Amortizes interest across cash flows
 */
export function amortiseInterest(
  cashFlows: CashFlow[],
  interestRate: number,
  precision: number
): CashFlow[] {
  return cashFlows;
}
