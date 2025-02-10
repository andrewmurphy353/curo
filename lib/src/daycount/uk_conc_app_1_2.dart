import 'convention.dart';
import 'day_count_factor.dart';
import 'day_count_time_period.dart';
import 'uk_conc_app_1_1.dart';

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
    switch (timePeriod) {
      case DayCountTimePeriod.year:
        break;
      case DayCountTimePeriod.month:
        break;
      case DayCountTimePeriod.week:
        break;
    }

    const factor = 0.0;
    return const DayCountFactor(factor, []);
  }
}
