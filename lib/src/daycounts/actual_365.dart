import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/utils.dart';

/// Implements the Actual/365 Fixed day count convention (also known as Act/365 Fixed).
///
/// Counts the actual number of calendar days between two dates (excluding the
/// end date) and divides by 365 to compute the year fraction. The time
/// component is ignored - all dates are normalized to midnight UTC.
///
/// Commonly used in sterling and euro money markets, and some fixed-income
/// instruments.
///
/// Example:
/// ```
///   From 2020-01-28 to 2020-02-28:
///   -> 31 days -> factor = 31/365 ≈ 0.08493151
/// ```
class Actual365 extends Convention {
  const Actual365({
    super.usePostDates = true,
    super.includeNonFinancingFlows = false,
    super.useXirrMethod = false,
  });

  @override
  DayCountFactor computeFactor(DateTime start, DateTime end) {
    if (end.isBefore(start)) {
      throw ArgumentError('end must not be before start');
    }

    final days = actualDays(start, end);

    final factor = days / 365.0;

    return DayCountFactor(
      primaryPeriodFraction: factor,
      discountFactorLog: days > 0 ? ['$days/365'] : ['0/365'],
    );
  }
}
