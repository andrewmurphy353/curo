import { US30360 } from './us-30-360';

describe('US30360', () => {
  let convention: US30360;

  beforeEach(() => {
    convention = new US30360();
  });

  it('should calculate factor correctly for same year, different months', () => {
    const d1 = new Date(Date.UTC(2022, 0, 15));  // Jan 15, 2022
    const d2 = new Date(Date.UTC(2022, 3, 15));  // Apr 15, 2022
    
    const result = convention.computeFactor(d1, d2);
    
    expect(result.numerator).toBe(90);  // 3 months * 30 days
    expect(result.denominator).toBe(360);
    expect(result.value).toBe(0.25);  // 90/360 = 0.25 (quarter of a year)
  });

  it('should handle end-of-month adjustments', () => {
    const d1 = new Date(Date.UTC(2022, 0, 31));  // Jan 31, 2022
    const d2 = new Date(Date.UTC(2022, 1, 28));  // Feb 28, 2022
    
    const result = convention.computeFactor(d1, d2);
    
    expect(result.numerator).toBe(28);
    expect(result.denominator).toBe(360);
    expect(result.value).toBe(28/360);
  });

  it('should work across multiple years', () => {
    const d1 = new Date(Date.UTC(2021, 0, 15));  // Jan 15, 2021
    const d2 = new Date(Date.UTC(2022, 0, 15));  // Jan 15, 2022
    
    const result = convention.computeFactor(d1, d2);
    
    expect(result.numerator).toBe(360);  // 1 year
    expect(result.denominator).toBe(360);
    expect(result.value).toBe(1);
  });
});
