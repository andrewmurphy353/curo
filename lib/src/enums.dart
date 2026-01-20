/// Enums used throughout the package for cash flow modelling and
/// financial calculations.
library;

/// Frequency of cash flows or compounding periods.
enum Frequency {
  /// Weekly.
  weekly,

  /// Every two weeks.
  fortnightly,

  /// Monthly.
  monthly,

  /// Every three months.
  quarterly,

  /// Every six months.
  halfYearly,

  /// Annual.
  yearly,
}

/// Timing of cash flows relative to the compounding period.
enum Mode {
  /// Cash flow occurs at the beginning of the period (e.g., advance payments).
  advance,

  /// Cash flow occurs at the end of the period (e.g., ordinary payments in arrear).
  arrear,
}

/// Base time unit for day count and compounding calculations.
enum DayCountTimePeriod {
  /// Daily.
  day,

  /// Weekly.
  week,

  /// Every two weeks.
  fortnight,

  /// Monthly.
  month,

  /// Every three months.
  quarter,

  /// Every six months.
  halfYear,

  /// Annual.
  year;

  /// Number of periods in a standard year.
  ///
  /// Used as the denominator in periodic rate calculations
  /// (e.g., 12 for monthly, 365 for daily).
  int get periodsInYear => switch (this) {
    DayCountTimePeriod.day => 365,
    DayCountTimePeriod.week => 52,
    DayCountTimePeriod.fortnight => 26,
    DayCountTimePeriod.month => 12,
    DayCountTimePeriod.quarter => 4,
    DayCountTimePeriod.halfYear => 2,
    DayCountTimePeriod.year => 1,
  };
}

/// Type classification of a cash flow.
enum CashFlowType { advance, payment, charge }

extension CashFlowTypeOrder on CashFlowType {
  int get idx => switch (this) {
    CashFlowType.advance => 0,
    CashFlowType.payment => 1,
    CashFlowType.charge => 2,
  };
}

/// Origin point for measuring day count factors.
enum DayCountOrigin {
  /// Time measured from the initial advance (drawdown) date.
  ///
  /// Used for APR/XIRR-style calculations where all periods are relative
  /// to the first financing flow.
  drawdown,

  /// Time measured between consecutive financing cash flows.
  ///
  /// Used for standard amortisation and effective rate calculations.
  neighbour,
}

/// Enum used internally to define the validation mode when solving for
/// an unknown value or interest rate.
enum ValidationMode {
  /// Requires all values to be known
  solveRate,
  /// Allows undefined advance OR payment values
  solveValue;
}