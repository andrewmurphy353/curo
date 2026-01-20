import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/utils.dart';

/// Implements the Actual/Actual (ISDA) day count convention.
///
/// Also known as Actual/Actual, Act/Act, or Act/Act (ISDA).
///
/// For periods within a single year: divides actual days by 365 (or 366 in
/// leap years). For multi-year periods: splits the calculation at year
/// boundaries, applying 365 or 366 to each segment based on whether that
/// year is a leap year.
///
/// The time component of dates is ignored — all dates are normalized to
/// midnight UTC.
///
/// Example:
/// ```
///   From 2020-01-28 to 2020-02-28 (2020 is leap year):
///   -> 31 days / 366 -> factor ≈ 0.08469945
///
///   Multi-year example (e.g., 2019-12-30 to 2021-01-02):
///   -> (2/365) + (366/366) + (1/365)
/// ```
class ActualISDA extends Convention {
  const ActualISDA({
    super.usePostDates = true,
    super.includeNonFinancingFlows = false,
    super.useXirrMethod = false,
  });

  @override
  DayCountFactor computeFactor(DateTime start, DateTime end) {
    if (end.isBefore(start)) {
      throw ArgumentError('end must not be before start');
    }

    if (end == start) {
      return const DayCountFactor(
        primaryPeriodFraction: 0.0,
        discountFactorLog: ['0/365'],
      );
    }

    final startNorm = normalizeToMidnightUtc(start);
    final endNorm = normalizeToMidnightUtc(end);

    final startYear = startNorm.year;
    final endYear = endNorm.year;

    if (startYear == endYear) {
      final days = endNorm.difference(startNorm).inDays;
      final denominator = isLeapYear(startYear) ? 366 : 365;
      final factor = days / denominator;

      return DayCountFactor(
        primaryPeriodFraction: factor,
        discountFactorLog: ['$days/$denominator'],
      );
    }

    // Multi-year: split by calendar year
    var factor = 0.0;
    final logEntries = <String>[];
    var current = startNorm;
    var currentYear = startYear;

    while (currentYear < endYear) {
      final yearEnd = DateTime.utc(currentYear, 12, 31);
      final daysInSegment =
          yearEnd.difference(current).inDays + 1; // Include end of year
      final denominator = isLeapYear(currentYear) ? 366 : 365;

      factor += daysInSegment / denominator;
      logEntries.add('$daysInSegment/$denominator');

      current = yearEnd.add(const Duration(days: 1)); // Jan 1 next year
      currentYear++;
    }

    // Final partial year
    final finalDays = endNorm.difference(current).inDays;
    if (finalDays > 0) {
      final denominator = isLeapYear(endYear) ? 366 : 365;
      factor += finalDays / denominator;
      logEntries.add('$finalDays/$denominator');
    }

    return DayCountFactor(
      primaryPeriodFraction: factor,
      discountFactorLog: logEntries,
    );
  }
}
