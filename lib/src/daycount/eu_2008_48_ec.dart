import '../utilities/dates.dart';
import 'convention.dart';
import 'day_count_factor.dart';
import 'day_count_time_period.dart';

/// The European Union Directive 2008/48/EC (Consumer Credit Directive)
/// day count convention, used exclusively within EU member states in the
/// computation of the Annual Percentage Rate of Charge (APRC) for
/// consumer credit agreements.
///
/// An APRC is used as a measure of the total cost of the credit to the
/// consumer, expressed as an annual percentage of the total amount of credit.
///
/// The document containing the rules for determining time intervals can
/// be found at
/// https://ec.europa.eu/info/sites/info/files/guidelines_final.pdf
/// (see ANNEX 1, section 4.1.1)
///
/// **UPDATE**:
///
/// The European Union Directive 2008/48/EC was repealed and replaced by
/// Directive (EU) 2023/2225. The key change relevant to our implementation
/// is found in EU Directive 2023/2225, Annex III, I. (c), which specifies
/// how to handle intervals between dates that cannot be expressed as whole
/// weeks, months, or years. It mandates that such intervals should be
/// expressed as a whole number of one of these periods combined with
/// additional days. Although Directive 2008/48/EC did not address this
/// issue explicitly, this implementation has always followed this method
/// and thus remains valid. For backward compatibility, the class name
/// 'EU200848EC' will not be changed to prevent disruptions in existing
/// codebases.
///
class EU200848EC extends Convention {
  final DayCountTimePeriod timePeriod;

  /// Provides an instance of the 2008/48/EC day count convention object
  /// for solving the Annual Percentage Rate (APR) of charge for consumer
  /// credit transactions throughout the European Union.
  ///
  /// [timePeriod] the interval between dates used in the calculation.
  /// Options are 'year', 'month' or 'week'. For the choice among years,
  /// months or weeks, consideration should be given to the frequency of
  /// drawdowns and payments within the cash flow series. Refer to the
  /// directive for further guidance. Default is 'month' if undefined.
  const EU200848EC({
    this.timePeriod = DayCountTimePeriod.month,
  })  : assert(
            timePeriod == DayCountTimePeriod.week ||
                timePeriod == DayCountTimePeriod.month ||
                timePeriod == DayCountTimePeriod.year,
            'Only year, month and week time periods are '
            'supported for EU APRC calculations'),
        super(
            usePostDates: true,
            includeNonFinancingFlows: true,
            useXirrMethod: true);

  /// Computes the time interval between dates, expressed in periods defined
  /// by the cash flow series frequency. Where the interval between dates
  /// used in the calculation cannot be expressed in whole periods, the
  /// interval is expressed in whole periods and remaining number of days
  /// divided by 365 (or 366 in a leap-year), calculated *backwards* from the
  /// cash flow date to the initial drawdown date.
  ///
  /// [d1] the initial drawdown date
  ///
  /// [d2] post date of the cash flow
  @override
  DayCountFactor computeFactor(DateTime d1, DateTime d2) {
    // Compute whole periods
    var wholePeriods = 0;
    final initialDrawdown = utcDate(d1);
    var startWholePeriod = utcDate(d2);
    final operandLog = <String>[];
    while (true) {
      DateTime tempDate;
      switch (timePeriod) {
        case DayCountTimePeriod.year:
          tempDate = rollMonth(startWholePeriod, -12, d2.day);
          break;
        case DayCountTimePeriod.week:
          tempDate = rollDay(startWholePeriod, -7);
          break;
        case DayCountTimePeriod.month:
          tempDate = rollMonth(startWholePeriod, -1, d2.day);
          break;
        case DayCountTimePeriod.halfYear:
        case DayCountTimePeriod.quarter:
        case DayCountTimePeriod.fortnight:
        case DayCountTimePeriod.day:
          throw StateError('The selected time period is not supported.');
      }
      if (!initialDrawdown.isAfter(tempDate)) {
        startWholePeriod = tempDate;
        wholePeriods++;
      } else {
        // Ensure that when both the initial drawdown and subsequent cash flow
        // dates fall on the last day of their respective months, the period is
        // calculated in whole months or years. This fix specifically addresses
        // the handling of February 28th or 29th, where previously periods were
        // incorrectly counted in days.
        switch (timePeriod) {
          case DayCountTimePeriod.year:
            if (initialDrawdown.month == tempDate.month &&
                initialDrawdown.day == tempDate.day) {
              // Same anniversary date
              break;
            }
            if (d1.month == d2.month &&
                hasMonthEndDay(d1) &&
                hasMonthEndDay(d2)) {
              startWholePeriod = initialDrawdown;
              wholePeriods++;
            }
            break;
          case DayCountTimePeriod.month:
            if (initialDrawdown.day == tempDate.day) {
              // Same day
              break;
            }
            if (initialDrawdown.day >= tempDate.day &&
                hasMonthEndDay(d1) &&
                hasMonthEndDay(d2)) {
              startWholePeriod = initialDrawdown;
              wholePeriods++;
            }
            break;
          case DayCountTimePeriod.week:
            // Based on actual days so not applicable
            break;
          case DayCountTimePeriod.halfYear:
          case DayCountTimePeriod.quarter:
          case DayCountTimePeriod.fortnight:
          case DayCountTimePeriod.day:
            // Not supported
            break;
        }
        break;
      }
    }

    var factor = 0.0;
    if (wholePeriods > 0) {
      factor = wholePeriods / timePeriod.periodsInYear;
      operandLog.add(
        DayCountFactor.operandsToString(wholePeriods, timePeriod.periodsInYear),
      );
    }

    // Compute days remaining if necessary
    if (!initialDrawdown.isAfter(startWholePeriod)) {
      final numerator = actualDays(initialDrawdown, startWholePeriod);
      final startDenPeriod = rollMonth(startWholePeriod, -12);

      int denominator;
      if (numerator == 0) {
        denominator = timePeriod.periodsInYear;
      } else {
        denominator = actualDays(startDenPeriod, startWholePeriod);
      }

      factor += numerator / denominator;

      if (numerator > 0 || operandLog.isEmpty) {
        operandLog.add(
          DayCountFactor.operandsToString(numerator, denominator),
        );
      }
    }

    return DayCountFactor(factor, operandLog);
  }
}
