/**
 * Determines how the day count intervals are calculated.
 */
export enum DayCountOrigin {
  /** Time periods measured between adjacent cash flow dates */
  Neighbor = 'neighbor',
  /** Time periods measured relative to the first drawdown date */
  Drawdown = 'drawdown'
}
