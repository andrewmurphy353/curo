import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/utils.dart';

/// Implements the 30/360 (EU) day count convention (also known as 30E/360 or
/// Eurobond basis).
///
/// Uses the formula:
///
/// >  `f = [360 × (Y2 − Y1) + 30 × (M2 − M1) + (D2 − D1)] / 360`
///
/// Where:
/// - D1 is the day of the start date, adjusted to 30 if 31
/// - D2 is the day of the end date, adjusted to 30 if 31
///
/// This convention assumes 30 days per month and 360 days per year.
/// The time component of dates is ignored — all dates are normalized to
/// midnight UTC.
///
/// Example:
/// ```
///   From 2020-01-31 to 2020-02-28:
///   -> D1 = 30, D2 = 28 -> numerator = 27 -> factor = 27/360 = 0.075
///
///   From 2020-01-31 to 2020-03-31:
///   -> D1 = 30, D2 = 30 -> numerator = 60 -> factor = 60/360 = 0.16666667
/// ```
class EU30360 extends Convention {
  const EU30360({
    super.usePostDates = true,
    super.includeNonFinancingFlows = false,
    super.useXirrMethod = false,
  });

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

    final dd1 = s.day;
    final mm1 = s.month;
    final yyyy1 = s.year;
    final dd2 = e.day;
    final mm2 = e.month;
    final yyyy2 = e.year;

    // Adjust day to 30 if 31
    final d1 = dd1 == 31 ? 30 : dd1;
    final d2 = dd2 == 31 ? 30 : dd2;

    final numerator = (360 * (yyyy2 - yyyy1) + 30 * (mm2 - mm1) + (d2 - d1))
        .abs();
    final factor = numerator / 360.0;

    return DayCountFactor(
      primaryPeriodFraction: factor,
      discountFactorLog: ['$numerator/360'],
    );
  }
}
