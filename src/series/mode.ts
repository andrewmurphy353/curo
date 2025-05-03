/**
 * Mode determines whether a cash flow occurs at the start or end of the
 * compounding period demarcated by cash flow frequency.
 */
export enum Mode {
  Advance = 'advance', // cash flows due at the beginning of a compounding period
  Arrear = 'arrear'    // cash flows due at the end of a compounding period
}
