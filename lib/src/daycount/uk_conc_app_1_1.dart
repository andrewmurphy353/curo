import '../../curo.dart';

/// The UK CONC App 1.1 day count convention is used exclusively within the
/// United Kingdom (UK) for computing the Annual Percentage Rate of Charge
/// (APRC) for consumer credit agreements secured on land.
///
/// This convention falls under the regulatory framework of the Financial
/// Services and Markets Act 2000 (FSMA 2000). More detailed information can
/// be found at:
/// [FCA Handbook - CONC App 1.1](https://www.handbook.fca.org.uk/handbook/CONC/App/1/1.html)
///
/// For computations related to *non-mortgage* lending, use the UK CONC App 1.2
/// [UKConcApp12] class.
///
/// This class implements the time computation rules as specified in App 1.1.10:
///
/// **Computation of time**:
///
/// - First, determine if the period between dates can be expressed as a whole
///   number of calendar months or weeks:
///   - If so, count the period in those respective units.
///
/// - If a period is both a whole number of calendar months and weeks:
///   - For single repayments, count the period in calendar months.
///   - For multiple repayments:
///     - If all payments are weekly, count in weeks.
///     - Otherwise, count in calendar months.
///
/// - For periods not consisting of a whole number of calendar months or weeks:
///   - **Count in years and days**:
///     - Convert whole months or weeks into years (e.g., 1 month = 1/12 of a year).
///     - Then, any remaining days are counted separately and converted into a
///       fraction of a year based on the number of days in the year (365 or 366
///       for leap years).
///
/// - A day can be considered as:
///   - One three hundred and sixty-fifth part of a year, or one three hundred
///     and sixty-sixth part in a leap year.
///   - Alternatively, 1/365.25 of a year.
///
/// - Every day is treated as a working day for calculation purposes.
///
class UKConcApp11 extends Convention {
  final bool hasSingleRepayment;
  final DayCountTimePeriod timePeriod;

  /// Constructs an instance of the UK CONC App 1.1 day count convention object
  /// for calculating the Annual Percentage Rate of Charge (APRC) in regulated
  /// mortgage contracts.
  ///
  /// - [hasSingleRepayment] specifies whether the calculation profile contains
  ///   a single repayment only .
  ///   - Defaults to 'false' if not specified.
  ///
  /// - [timePeriod] specifies the interval for calculation. Valid values are
  ///   'month' or 'week'. This parameter influences how the period is counted:
  ///   - If the period is a whole number of months or weeks, it's counted in
  ///     those units respectively.
  ///   - If not, the parameter is used to convert the whole part of the period
  ///     into years before counting the remaining days separately.
  ///   - Defaults to 'month' if not specified.
  ///
  const UKConcApp11({
    this.hasSingleRepayment = false,
    this.timePeriod = DayCountTimePeriod.month,
  })  : assert(timePeriod != DayCountTimePeriod.year,
            'The year day count time period is not a valid option'),
        super(
            usePostDates: true,
            includeNonFinancingFlows: true,
            useXirrMethod: true);

  /// Computes the time interval between two dates based on the [timePeriod].
  ///
  /// - [d1] The initial drawdown date or relevant starting date.
  /// - [d2] The date of the cash flow or ending date.
  ///
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
        : d1.day == d2.day || hasMonthEndDay(d1) && hasMonthEndDay(d2);

    switch (timePeriod) {
      case DayCountTimePeriod.week:
        wholePeriods = actualDays(d1, d2) ~/ 7;
        if (isWholeNumberOfWeeks) {
          if (isWholeNumberOfMonths && hasSingleRepayment) {
            // Whole month/s overrides
            wholePeriods = monthsBetweenDates(d1, d2);
            factor = wholePeriods / DayCountTimePeriod.month.periodsInYear;
            operandLog.add(
              DayCountFactor.operandsToString(
                wholePeriods,
                DayCountTimePeriod.month.periodsInYear,
              ),
            );
            return DayCountFactor(factor, operandLog);
          }
          // Whole weeks
          factor = wholePeriods / timePeriod.periodsInYear;
          operandLog.add(
            DayCountFactor.operandsToString(
              wholePeriods,
              timePeriod.periodsInYear,
            ),
          );
          return DayCountFactor(factor, operandLog);
        } else {
          // Handle periods *not* consisting of a whole number of weeks:
          // Count in years and days by converting whole weeks into years
          // (e.g., 1 week = 1/52 of a year), then count any remaining days
          // and convert into a fraction of a year based on the number of days
          // in the year (365 or 366 for leap years).

          // Whole period
          factor = wholePeriods / timePeriod.periodsInYear;
          if (wholePeriods > 0) {
            operandLog.add(
              DayCountFactor.operandsToString(
                wholePeriods,
                timePeriod.periodsInYear,
              ),
            );
          }

          // Remaining days
          final wholePeriodEnd = rollDay(d1, wholePeriods * 7);
          factor =
              _processRemainingDays(d1, d2, wholePeriodEnd, factor, operandLog);
          return DayCountFactor(factor, operandLog);
        }

      case DayCountTimePeriod.month:
      default:
        wholePeriods = monthsBetweenDates(d1, d2);
        if (isWholeNumberOfMonths) {
          factor = wholePeriods / timePeriod.periodsInYear;
          operandLog.add(
            DayCountFactor.operandsToString(
              wholePeriods,
              timePeriod.periodsInYear,
            ),
          );
          return DayCountFactor(factor, operandLog);
        } else {
          // Handle periods not consisting of a whole number of months:
          // Count in years and days by converting whole months into years
          // (e.g., 1 month = 1/12 of a year), then count any remaining days
          // and convert into a fraction of a year based on the number of days
          // in the year (365 or 366 for leap years).

          // Whole period
          factor = wholePeriods / timePeriod.periodsInYear;
          if (wholePeriods > 0) {
            operandLog.add(
              DayCountFactor.operandsToString(
                wholePeriods,
                timePeriod.periodsInYear,
              ),
            );
          }

          // Remaining days
          final wholePeriodEnd = rollMonth(d1, wholePeriods, d1.day);
          factor =
              _processRemainingDays(d1, d2, wholePeriodEnd, factor, operandLog);
          return DayCountFactor(factor, operandLog);
        }
    }
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
      // Days fall within same year
      daysRemaining = d2.difference(wholePeriodEnd).inDays;
      daysInYear = isLeapYear(d2.year) ? 366 : 365;
      factor += daysRemaining / daysInYear;
      operandLog.add(
        DayCountFactor.operandsToString(daysRemaining, daysInYear),
      );
    } else {
      // Days between wholePeriodEnd and year end
      final yearEnd = DateTime(wholePeriodEnd.year, 12, 31);
      daysRemaining = yearEnd.difference(wholePeriodEnd).inDays;
      daysInYear = isLeapYear(wholePeriodEnd.year) ? 366 : 365;
      factor += daysRemaining / daysInYear;
      operandLog.add(
        DayCountFactor.operandsToString(daysRemaining, daysInYear),
      );

      // Days between year end and date d2
      daysRemaining = d2.difference(yearEnd).inDays;
      daysInYear = isLeapYear(d2.year) ? 366 : 365;
      factor += daysRemaining / daysInYear;
      operandLog.add(
        DayCountFactor.operandsToString(daysRemaining, daysInYear),
      );
    }
    return factor;
  }
}
