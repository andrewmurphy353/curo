import { Convention, ConventionOptions } from './convention';
import { DayCountFactor } from './day-count-factor';

/**
 * US 30/360 day count convention.
 * 
 * Convention accounts for days between cash flow dates based on a 30 day month, 
 * 360 day year as documented on Wikipedia. This is the default convention used 
 * by the Hewlett Packard HP12C and similar financial calculators.
 */
export class US30360 extends Convention {
  constructor(options: ConventionOptions = {}) {
    super(options);
  }

  computeFactor(d1: Date, d2: Date): DayCountFactor {
    if (d1.getTime() > d2.getTime()) {
      [d1, d2] = [d2, d1];
    }

    let y1 = d1.getUTCFullYear();
    let y2 = d2.getUTCFullYear();
    let m1 = d1.getUTCMonth() + 1;  // JavaScript months are 0-indexed
    let m2 = d2.getUTCMonth() + 1;
    let day1 = d1.getUTCDate();
    let day2 = d2.getUTCDate();

    if (day1 === 31) {
      day1 = 30;
    }
    if (day2 === 31 && day1 >= 30) {
      day2 = 30;
    }

    const numerator = (y2 - y1) * 360 + (m2 - m1) * 30 + (day2 - day1);
    
    const denominator = 360;
    
    const value = numerator / denominator;

    return { numerator, denominator, value };
  }
}
