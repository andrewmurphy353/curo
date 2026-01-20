import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/utils.dart';

/// Implements the Actual/360 day count convention.
///
/// Counts the actual number of calendar days between two dates (excluding the
/// end date) and divides by 360. The time component of dates is ignored —
/// all dates are normalized to midnight UTC.
///
/// This convention is common in money markets (e.g., EURIBOR, commercial
/// paper).
///
/// Example:
/// ```
/// From 2020-01-28 14:30:00 to 2020-02-28 09:15:00:
///   -> Treated as 2020-01-28 to 2020-02-28
///   -> 31 days -> factor = 31/360 ≈ 0.08611111
/// ```
class Actual360 extends Convention {
  const Actual360({
    super.usePostDates = true,
    super.includeNonFinancingFlows = false,
    super.useXirrMethod = false,
  });

  @override
  DayCountFactor computeFactor(DateTime start, DateTime end) {
    if (end.isBefore(start)) {
      throw ArgumentError('end must not be before start');
    }

    final startMidnight = normalizeToMidnightUtc(start);
    final endMidnight = normalizeToMidnightUtc(end);

    // difference.inDays excludes the end date and returns 0 for same day
    final days = endMidnight.difference(startMidnight).inDays;

    final factor = days / 360.0;

    return DayCountFactor(
      primaryPeriodFraction: factor,
      discountFactorLog: days > 0 ? ['$days/360'] : ['0/360'],
    );
  }
}
