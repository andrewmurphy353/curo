import '../../curo.dart';

/// The UK CONC App 1.2 day count convention is used exclusively within the
/// United Kingdom (UK) for computing the Annual Percentage Rate of Charge
/// (APRC) for consumer credit agreements **other than those secured on land**.
///
/// This convention is regulated under the Financial Services and Markets Act
/// 2000 (FSMA 2000). Detailed information is available at:
/// [FCA Handbook - CONC App 1.2](https://www.handbook.fca.org.uk/handbook/CONC/App/1/2.html)
///
/// For computations related to *mortgage* lending, use the UK CONC App 1.1
/// [UKConcApp11] class.
///
/// This class implements the time computation rules as specified in App 1.2.6:
///
/// **Computation of time**:
///
/// - The starting date is set to the first drawdown date.
///
/// - Intervals between dates are calculated in years or fractions thereof.
///
/// - A year can be considered as having:
///   - 365 days (366 in leap years)
///   - 52 weeks
///   - 12 equal months, where an equal month is assumed to have 30.41666 days.
///
/// - For periods not consisting of whole years, months, or weeks, the time is
///   converted into a fraction of a year based on the number of days in the
///   year (365 or 366 for leap years).
///
class UKConcApp12 extends Convention {
  final DayCountTimePeriod timePeriod;

  /// Constructs an instance of the UK CONC App 1.2 day count convention object
  /// for calculating the Annual Percentage Rate of Charge (APRC) in consumer
  /// credit agreements **other than those secured on land**.
  ///
  /// - [timePeriod] specifies the interval for calculation. Valid values are
  ///   'year', 'month', or 'week'. This parameter influences how the period is
  ///   counted:
  ///   - If the period is a whole number of years, months, or weeks, it's
  ///     counted in those units respectively.
  ///   - If not, the period is converted into years or fractions thereof:
  ///     - Time not fitting into whole units is calculated as a fraction of a
  ///       year, using 365 or 366 days depending on whether it's a leap year.
  ///   - Defaults to 'month' if not specified.
  ///
  const UKConcApp12({
    this.timePeriod = DayCountTimePeriod.month,
  }) : super(
            usePostDates: true,
            includeNonFinancingFlows: true,
            useXirrMethod: true);

  /// Computes the time interval between two dates based on the [timePeriod].
  ///
  /// - [d1] The initial drawdown date or relevant starting date.
  /// - [d2] The date of the cash flow or ending date.
  @override
  DayCountFactor computeFactor(DateTime d1, DateTime d2) {
    double factor = 0.0;
    final operandLog = <String>[];
    final isSameDated = d2.difference(d1).inDays == 0;

    switch (timePeriod) {
      case DayCountTimePeriod.week:
        final isWholeNumberOfWeeks =
            isSameDated ? false : actualDays(d1, d2) % 7 == 0;
        if (isWholeNumberOfWeeks) {
          final wholePeriods = actualDays(d1, d2) ~/ 7;
          factor = wholePeriods / timePeriod.periodsInYear;
          operandLog.add(
            DayCountFactor.operandsToString(
              wholePeriods,
              timePeriod.periodsInYear,
            ),
          );
          return DayCountFactor(factor, operandLog);
        }
        break;
      case DayCountTimePeriod.month:
        final isWholeNumberOfMonths = isSameDated
            ? false
            : d1.day == d2.day || hasMonthEndDay(d1) && hasMonthEndDay(d2);

        if (isWholeNumberOfMonths) {
          final wholePeriods = monthsBetweenDates(d1, d2);
          factor = wholePeriods / timePeriod.periodsInYear;
          operandLog.add(
            DayCountFactor.operandsToString(
              wholePeriods,
              timePeriod.periodsInYear,
            ),
          );
          return DayCountFactor(factor, operandLog);
        }
        break;
      case DayCountTimePeriod.year:
        final isWholeNumberOfYears = isSameDated
            ? false
            : (d1.day == d2.day || hasMonthEndDay(d1) && hasMonthEndDay(d2)) &&
                d1.month == d2.month;
        if (isWholeNumberOfYears) {
          final wholePeriods = monthsBetweenDates(d1, d2) ~/ 12;
          factor = wholePeriods / timePeriod.periodsInYear;
          operandLog.add(
            DayCountFactor.operandsToString(
              wholePeriods,
              timePeriod.periodsInYear,
            ),
          );
          return DayCountFactor(factor, operandLog);
        }
        break;
    }

    // For periods not consisting of whole years, months, or weeks, the time is
    // converted into a fraction of a year based on the number of days in the
    // year (365 or 366 for leap years).
    if (d1.year == d2.year) {
      final numberOfDays = actualDays(d1, d2);
      print('Same year: days: $numberOfDays');
      factor = numberOfDays / (isLeapYear(d1.year) ? 366 : 365);
      operandLog.add(
        DayCountFactor.operandsToString(
          numberOfDays,
          isLeapYear(d1.year) ? 366 : 365,
        ),
      );
    } else {
      // From d1 to the end of d1.year
      final endOfYear1 = DateTime(d1.year, 12, 31);
      final daysFirstYear = actualDays(d1, endOfYear1);
      print('Year 1: days: $daysFirstYear');

      factor += daysFirstYear / (isLeapYear(d1.year) ? 366 : 365);
      operandLog.add(
        DayCountFactor.operandsToString(
          daysFirstYear,
          isLeapYear(d1.year) ? 366 : 365,
        ),
      );

      // Full years between d1.year and d2.year
      for (int year = d1.year + 1; year < d2.year; year++) {
        final daysInYear = isLeapYear(year) ? 366 : 365;
        factor += 1.0;
        operandLog.add(
          DayCountFactor.operandsToString(daysInYear, daysInYear),
        );
      }

      // From the start of d2.year to d2
      final startOfYear2 = DateTime(d2.year, 1, 1);
      final daysLastYear = actualDays(startOfYear2, d2) + 1;
      factor += daysLastYear / (isLeapYear(d2.year) ? 366 : 365);
      operandLog.add(
        DayCountFactor.operandsToString(
          daysLastYear,
          isLeapYear(d2.year) ? 366 : 365,
        ),
      );
    }

    return DayCountFactor(factor, operandLog);
  }
}
