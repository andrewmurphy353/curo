import '../../curo.dart';

/// The UK CONC App day count convention is used in the United Kingdom (UK) for
/// computing the Annual Percentage Rate of Charge (APRC) for consumer credit
/// agreements, under the Financial Services and Markets Act 2000 (FSMA 2000).
///
/// This class supports two contexts based on [isSecuredOnLand]:
/// - **Secured on land (CONC App 1.1)**: For mortgage-related agreements.
///   See: [FCA Handbook - CONC App 1.1](https://www.handbook.fca.org.uk/handbook/CONC/App/1/1.html)
/// - **Not secured on land (CONC App 1.2)**: For other consumer credit
///   agreements.
///   See: [FCA Handbook - CONC App 1.2](https://www.handbook.fca.org.uk/handbook/CONC/App/1/2.html)
///
/// **Computation of Time**:
/// - Starts from the first drawdown date.
/// - Intervals are expressed in years or fractions:
///   - Year = 365 days (366 in leap years), 52 weeks, or 12 equal months.
///   - An equal month is 30.41666 days (365/12) in the App 1.2 APR formula.
/// - Periods are counted as:
///   - Whole calendar months (1/12 year) or weeks (1/52 year) if exact.
///   - If both (e.g., Jan 31 to Feb 28, 28 days = 1 month = 4 weeks) and
///     [isSecuredOnLand] is true:
///     - Single payment: Use months (1/12 year, CONC App 1.1.10 R (4)(a)).
///     - Multiple payments: Use [timePeriod] (weekly → 1/52, else 1/12).
///   - Otherwise, use [timePeriod].
/// - Non-whole periods: Whole months or weeks per [timePeriod], then residual
///   days (1/365 or 1/366).
/// - Every day is a working day (CONC App 1.1.8 R, 1.2.8 R).
///
class UKConcApp extends Convention {
  final bool isSecuredOnLand;
  final bool hasSinglePayment;
  final DayCountTimePeriod timePeriod;

  /// Constructs a UK CONC App day count convention object for APRC
  /// calculations.
  ///
  /// - [isSecuredOnLand]: True for agreements secured on land (CONC App 1.1),
  ///   false for other agreements (CONC App 1.2). Enables single payment edge
  ///   case when true.
  /// - [hasSinglePayment]: True if the profile has one payment; forces months
  ///   for whole-month periods when [isSecuredOnLand] is true (defaults to
  ///   false).
  ///   Ignored if [isSecuredOnLand] is false.
  /// - [timePeriod]: Repayment frequency — 'month' (default) or 'week':
  ///   - 'month': Uses months if whole months.
  ///   - 'week': Uses weeks if whole weeks.
  ///   - For non-whole periods, converts whole units to years, then adds
  ///     residual days.
  const UKConcApp({
    this.isSecuredOnLand = false,
    this.hasSinglePayment = false,
    this.timePeriod = DayCountTimePeriod.month,
  })  : assert(timePeriod != DayCountTimePeriod.year,
            'The year time period is not valid for interval counting'),
        super(
            usePostDates: true,
            includeNonFinancingFlows: true,
            useXirrMethod: true);

  /// Check if a date is the last day of its month per CONC calendar month
  /// rules.
  ///
  /// Returns true if [date] is the final day of its month, aligning with the
  /// CONC App's use of "whole number of calendar months" (e.g., CONC App
  /// 1.1.10 R, 1.2.6 R). For non-leap years and most months, this is
  /// straightforward (e.g., Jan 31, Apr 30). For February in leap years, both
  /// Feb 28 and Feb 29 are considered month-end days to ensure consistency with
  /// calendar month spans:
  /// - Jan 31 to Feb 28 (leap year) = 1 month, despite 29 days total.
  /// - Jan 31 to Feb 29 = 1 month, as Feb 29 is the true end.
  /// This dual treatment ensures periods like Jan 31 to Feb 28/29 are counted
  /// as whole months when applicable, per FCA intent for consumer credit APRC
  /// calculations.
  ///
  bool _hasMonthEndDay(DateTime date) {
    if (date.month == 2 && isLeapYear(date.year)) {
      return date.day == 29 || date.day == 28;
    }
    return daysInMonth[date.month - 1] == date.day;
  }

  @override
  DayCountFactor computeFactor(DateTime d1, DateTime d2) {
    int wholePeriods = 0;
    double factor = 0.0;
    final operandLog = <String>[];

    final isSameDated = d2.difference(d1).inDays == 0;
    final isWholeNumberOfWeeks =
        isSameDated ? false : actualDays(d1, d2) % 7 == 0;
    final isWholeNumberOfMonths = isSameDated
        ? false
        : d1.day == d2.day || (_hasMonthEndDay(d1) && _hasMonthEndDay(d2));

    switch (timePeriod) {
      case DayCountTimePeriod.week:
        wholePeriods = actualDays(d1, d2) ~/ 7;
        if (isWholeNumberOfWeeks) {
          if (isSecuredOnLand && isWholeNumberOfMonths && hasSinglePayment) {
            wholePeriods = monthsBetweenDates(d1, d2);
            factor = wholePeriods / DayCountTimePeriod.month.periodsInYear;
            operandLog.add(DayCountFactor.operandsToString(
                wholePeriods, DayCountTimePeriod.month.periodsInYear));
            return DayCountFactor(factor, operandLog);
          }
          factor = wholePeriods / timePeriod.periodsInYear;
          operandLog.add(DayCountFactor.operandsToString(
              wholePeriods, timePeriod.periodsInYear));
          return DayCountFactor(factor, operandLog);
        }
        break;

      case DayCountTimePeriod.month:
      default:
        wholePeriods = monthsBetweenDates(d1, d2);
        if (isWholeNumberOfMonths) {
          factor = wholePeriods / timePeriod.periodsInYear;
          operandLog.add(DayCountFactor.operandsToString(
              wholePeriods, timePeriod.periodsInYear));
          return DayCountFactor(factor, operandLog);
        }
        break;
    }

    // Non-whole periods: whole units then residual days
    factor = wholePeriods / timePeriod.periodsInYear;
    print('WP: $wholePeriods, PIY: ${timePeriod.periodsInYear}');
    if (wholePeriods > 0) {
      operandLog.add(DayCountFactor.operandsToString(
          wholePeriods, timePeriod.periodsInYear));
    }
    final wholePeriodEnd = timePeriod == DayCountTimePeriod.week
        ? rollDay(d1, wholePeriods * 7)
        : rollMonth(d1, wholePeriods, d1.day);
    factor = _processRemainingDays(d1, d2, wholePeriodEnd, factor, operandLog);
    return DayCountFactor(factor, operandLog);
  }

  double _processRemainingDays(
    DateTime d1,
    DateTime d2,
    DateTime wholePeriodEnd,
    double factor,
    operandLog,
  ) {
    int daysRemaining;
    int daysInYear;

    if (wholePeriodEnd.year == d2.year) {
      daysRemaining = d2.difference(wholePeriodEnd).inDays;
      daysInYear = isLeapYear(d2.year) ? 366 : 365;
      factor += daysRemaining / daysInYear;
      operandLog
          .add(DayCountFactor.operandsToString(daysRemaining, daysInYear));
    } else {
      final yearEnd = DateTime(wholePeriodEnd.year, 12, 31);
      daysRemaining = yearEnd.difference(wholePeriodEnd).inDays;
      daysInYear = isLeapYear(wholePeriodEnd.year) ? 366 : 365;
      factor += daysRemaining / daysInYear;
      operandLog
          .add(DayCountFactor.operandsToString(daysRemaining, daysInYear));

      daysRemaining = d2.difference(yearEnd).inDays;
      daysInYear = isLeapYear(d2.year) ? 366 : 365;
      factor += daysRemaining / daysInYear;
      operandLog
          .add(DayCountFactor.operandsToString(daysRemaining, daysInYear));
    }
    return factor;
  }
}
