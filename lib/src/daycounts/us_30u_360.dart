import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/utils.dart';

/// Implements the US 30U/360 day count convention (also known as 30U/360).
///
/// A variant of US 30/360 used in some financial calculators (e.g., HP12C)
/// to better align real calendar dates, especially in February.
///
/// Key differences from standard US 30/360:
/// - February is treated as having 30 days if the start or end date falls on
///   February 28 (non-leap) or February 29 (leap).
/// - Exception: In non-leap years, if start or end is February 29, treat
///   as 29 days.
/// - D1 = 30 if start day is 31
/// - D2 = 30 if end day is 31
///
/// This results in consistent behavior with legacy financial calculators
/// when using actual calendar dates.
///
class US30U360 extends Convention {
  const US30U360({
    super.usePostDates = true,
    super.includeNonFinancingFlows = false,
    super.useXirrMethod = false,
  });

  /// Computes the adjusted day difference, applying February 30-day rule.
  int _dayDifference(DateTime start, DateTime end, int d1, int d2) {
    final isD1FebLast =
        start.month == DateTime.february && hasMonthEndDay(start);
    final isD2FebLast = end.month == DateTime.february && hasMonthEndDay(end);

    if (isD1FebLast && d2 != d1) {
      if (!isLeapYear(start.year) && d2 == 29) {
        // Non-leap year, end on Feb 29 -> treat Feb as 29 days
        return d2 - (d1 + (29 - d1));
      }
      return d2 - (d1 + (30 - d1));
    }

    if (isD2FebLast && d2 != d1) {
      if (!isLeapYear(end.year) && d1 == 29) {
        // Non-leap year, start on Feb 29 -> treat Feb as 29 days
        return (d2 + (29 - d2)) - d1;
      }
      return (d2 + (30 - d2)) - d1;
    }

    return d2 - d1;
  }

  @override
  DayCountFactor computeFactor(DateTime start, DateTime end) {
    if (end.isBefore(start)) {
      throw ArgumentError('end must not be before start');
    }

    if (start == end) {
      return const DayCountFactor(
        primaryPeriodFraction: 0.0,
        discountFactorLog: ['0/360'],
      );
    }

    final s = normalizeToMidnightUtc(start);
    final e = normalizeToMidnightUtc(end);

    // D1: 31 -> 30
    final d1 = s.day == 31 ? 30 : s.day;
    // D2: 31 -> 30
    final d2 = e.day == 31 ? 30 : e.day;

    final daysDiff = _dayDifference(s, e, d1, d2);

    final numerator =
        360 * (e.year - s.year) + 30 * (e.month - s.month) + daysDiff;
    final factor = numerator / 360.0;

    // Format operand: whole years as integer, otherwise "num/360"
    final operand = (numerator % 360 == 0)
        ? '${numerator ~/ 360}'
        : '$numerator/360';

    return DayCountFactor(
      primaryPeriodFraction: factor,
      discountFactorLog: [operand],
    );
  }
}
