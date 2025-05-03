/**
 * Perform gaussian rounding, also known as "bankers" rounding, convergent
 * rounding, Dutch rounding, or odd–even rounding. This is a method of
 * rounding without statistical bias; regular rounding has a native upwards
 * bias. Gaussian rounding avoids this by rounding to the nearest even
 * number.
 *
 * @param num number to round
 * @param precision number of decimal places (default 0)
 * @returns rounded number
 */
export function gaussRound(num: number, precision: number = 0): number {
  const d = Math.abs(precision);
  const m = Math.pow(10, d);
  const n = parseFloat((num * m).toFixed(8));
  const i = Math.floor(n);
  const f = n - i;
  const e = 1e-8;
  
  const r = f > 0.5 - e && f < 0.5 + e
    ? i % 2 === 0
      ? i
      : i + 1
    : Math.round(n);
    
  return r / m;
}
