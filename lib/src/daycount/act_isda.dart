import '../utilities/dates.dart';
import 'convention.dart';
import 'day_count_factor.dart';

/// The Actual/ISDA day count convention which follows the ISDA understanding
/// of the actual/actual convention included in the 1991 ISDA Definitions.
///
/// This convention specifies the actual number of days in the Calculation
/// Period in respect of which payment is being made is divided by 365 (or,
/// if any portion of that Calculation Period falls in a leap year, the sum of:
/// * the actual number of days in that portion of the Calculation Period
/// falling in a leap year divided by 366, and;
/// * the actual number of days in that portion of the Calculation Period
/// falling in a non-leap year divided by 365)
///
/// This convention is also known as "Actual/Actual", "Actual/Actual (ISDA)",
/// "Act/Act", or "Act/Act (ISDA)"
class ActISDA extends Convention {
  /// Provides an instance of the Actual/Actual (ISDA) day count convention.
  ///
  /// The default day count instance is suitable for use in all compound
  /// interest calculations. With the default setup interest is calculated
  /// on the reducing capital balance and is compounded at a frequency
  /// typically determined by the time interval between cash flows.
  ///
  /// For non-compound interest calculations, such as solving for unknowns
  /// on the basis of an eXtended Internal Rate of Return (XIRR), set
  /// [useXirrMethod] to *true*. With this setup the day count is calculated
  /// with reference to the first cash flow date in the series.
  ///
  /// [usePostDates] (optional) defines whether the day count between
  /// cash flows is computed using cash flow post dates (true), or
  /// alternatively cash flow value dates (false). Default is true.
  ///
  /// [includeNonFinancingFlows] (optional) determines whether non-financing
  /// cash flows, such as charges or fees within the cash flow profile, are
  /// included in the computation of periodic factors. Default is false.
  ///
  /// [useXirrMethod] (optional) determines whether to use the XIRR method
  /// of determining time periods between cash flow dates (true). Default
  /// is false.
  const ActISDA(
      {bool usePostDates = true,
      bool includeNonFinancingFlows = false,
      bool useXirrMethod = false})
      : super(
            usePostDates: usePostDates,
            includeNonFinancingFlows: includeNonFinancingFlows,
            useXirrMethod: useXirrMethod);

  @override
  DayCountFactor computeFactor(DateTime d1, DateTime d2) {
    int startDateYear = d1.year;
    final endDateYear = d2.year;
    int numerator;
    int denominator;
    double factor = 0.0;

    if (startDateYear == endDateYear) {
      // Common case - both dates fall within the same leap-year or
      // non leap-year, so no need to split factor calculation
      numerator = actualDays(d1, d2);
      denominator = isLeapYear(startDateYear) ? 366 : 365;
      factor = numerator / denominator;
      return DayCountFactor(
        factor,
        [DayCountFactor.operandsToString(numerator, denominator)],
      );
    } else if (!hasLeapYear(startDateYear, endDateYear)) {
      // Dates do not span or fall within a leap year
      numerator = actualDays(d1, d2);
      factor = numerator / 365;
      return DayCountFactor(
        factor,
        [DayCountFactor.operandsToString(numerator, 365)],
      );
    } else {
      // There is a leap year in the date range so split factor calculation.
      // Handle partial period in year 1, and whole years thereafter
      // (if necessary)
      final operandLog = <String>[];
      DateTime yearEnd;
      while (startDateYear != endDateYear) {
        yearEnd = DateTime.utc(startDateYear, 12, 31);
        numerator = actualDays(d1, yearEnd);
        denominator = isLeapYear(startDateYear) ? 366 : 365;
        factor += numerator / denominator;
        if (numerator > 0) {
          // Do not log when numerator 0 (it will be when start date is
          // last day of year)
          operandLog.add(
            DayCountFactor.operandsToString(numerator, denominator),
          );
        }
        d1 = yearEnd;
        startDateYear++;
      }

      // Process partial final year period
      numerator = actualDays(d1, d2);
      denominator = isLeapYear(endDateYear) ? 366 : 365;
      factor += numerator / denominator;
      operandLog.add(
        DayCountFactor.operandsToString(numerator, denominator),
      );

      return DayCountFactor(factor, operandLog);
    }
  }
}
