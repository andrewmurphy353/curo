/// The day count origin demarcates the start date used in determining
/// the number of days in a time period. Time periods are computed with
/// reference to:
///
/// * [drawdown] date: the *initial drawdown* post date. This is used
/// in Annual Percentage Rate (APR) and eXtended Internal Rate of
/// Return (XIRR) interest rate calculations; or
///
/// * [neighbour] date: a neighbouring cash flow date. This demarcates the
/// compounding period between cash flows and is the common use case
/// when solving unknown values and/or implicit effective interest rates.
enum DayCountOrigin {
  /// Days in a period are counted with reference to the initial
  /// draw-down date
  drawdown,

  /// Days in a period are counted with reference to a neighbouring
  /// cash-flow date
  neighbour,
}
