import '../../curo.dart';

/// The 30U/360 day count convention is similar to the [US30360] day count
/// convention and differs only in how days in February are treated.
///
/// Instead of considering February to have 28 days, or 29 days in a leap
/// year, as with [US30360], this convention considers February to have
/// 30 days when either the start and/or end day falls on 28th (non-leap year)
/// or 29th (leap year).
///
/// The only exception to this is in non-leap years when a start or end date
/// falls on the 29th. In that case February is considered to have 29 days.
///
/// The handling of February's days in this manner might differ slightly
/// from traditional methods. However, once adjustments are applied, this
/// approach yields results identical to those from financial calculators
/// like the HP12C, even though it uses actual calendar days in its
/// calculations.
///
class US30U360 extends Convention {
  ///
  /// Provides an instance of the 30U/360 day count convention object.
  ///
  /// The default day count instance is suitable for use in all compound
  /// interest calculations. With the default setup interest is calculated
  /// on the reducing capital balance and is compounded at a frequency
  /// typically determined by the time interval between cash flows.
  ///
  /// For non-compound interest calculations, such as solving for unknowns
  /// on the basis of an eXtended Internal Rate of Return (XIRR), set the
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
  ///
  const US30U360({
    bool usePostDates = true,
    bool includeNonFinancingFlows = false,
    bool useXirrMethod = false,
  }) : super(
            usePostDates: usePostDates,
            includeNonFinancingFlows: includeNonFinancingFlows,
            useXirrMethod: useXirrMethod);

  @override
  DayCountFactor computeFactor(DateTime d1, DateTime d2) {
    final dt1 = DateTime.utc(d1.year, d1.month, (d1.day == 31) ? 30 : d1.day);
    final dt2 = DateTime.utc(d2.year, d2.month, (d2.day == 31) ? 30 : d2.day);
    final daysDiff = dayDifference(dt1, dt2);
    final days =
        ((d2.year - d1.year) * 360) + ((d2.month - d1.month) * 30) + daysDiff;

    final numerator = days.abs();
    final factor = numerator / 360;

    return DayCountFactor(
      factor,
      [DayCountFactor.operandsToString(numerator, 360)],
    );
  }

  int dayDifference(DateTime d1, DateTime d2) {
    final isD1LastDay = isLastDayOfMonth(d1);
    final isD2LastDay = isLastDayOfMonth(d2);

    if (isD1LastDay && isD2LastDay) {
      return d2.day + (d1.day - d2.day) - d1.day;
    }
    if (isD1LastDay && d1.month == 2 && d1.day != d2.day) {
      if (!isLeapYear(d1.year) && d2.day == 29) {
        // Special case: treat non-leap Feb as 29 days when
        // d2.day == 29
        return d2.day - (d1.day + (29 - d1.day));
      }
      return d2.day - (d1.day + (30 - d1.day));
    }
    if (isD2LastDay && d2.month == 2 && d2.day != d1.day) {
      if (!isLeapYear(d2.year) && d1.day == 29) {
        // Special case: treat non-leap Feb as 29 days when
        // d1.day == 29
        return (d2.day + (29 - d2.day)) - d1.day;
      }
      return (d2.day + (30 - d2.day)) - d1.day;
    }
    return d2.day - d1.day;
  }

  /// Returns true if [date] is the last day of the adjusted 30-day month,
  /// or the last day of February regardless of leap year status.
  bool isLastDayOfMonth(DateTime date) {
    final startOfNextMonth = DateTime(date.year, date.month + 1, 1);
    final DateTime endOfThisMonth;
    switch (date.month) {
      case 1: // Jan
      case 3: // Mar
      case 5: // May
      case 7: // Jul
      case 8: // Aug
      case 10: // Oct
      case 12: // Dec
        endOfThisMonth = startOfNextMonth.subtract(
          const Duration(days: 2),
        );
        break;
      case 2: // Feb
      case 4: // Apr
      case 6: // Jun
      case 9: // Sep
      case 11: // Nov
      default:
        endOfThisMonth = startOfNextMonth.subtract(
          const Duration(days: 1),
        );
    }
    return date.year == endOfThisMonth.year &&
        date.month == endOfThisMonth.month &&
        date.day == endOfThisMonth.day;
  }
}
