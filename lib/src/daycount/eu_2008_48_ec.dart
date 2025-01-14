import '../utilities/dates.dart';
import 'convention.dart';
import 'day_count_factor.dart';

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
class EU200848EC extends Convention {
  final EUTimePeriod timePeriod;

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
    this.timePeriod = EUTimePeriod.month,
  }) : super(
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
    final int periodsInYear;
    switch (timePeriod) {
      case EUTimePeriod.year:
        periodsInYear = 1;
        break;
      case EUTimePeriod.week:
        periodsInYear = 52;
        break;
      case EUTimePeriod.month:
        periodsInYear = 12;
        break;
    }
    final initialDrawdown = utcDate(d1);
    var startWholePeriod = utcDate(d2);
    final operandLog = <String>[];
    while (true) {
      DateTime tempDate;
      switch (timePeriod) {
        case EUTimePeriod.year:
          tempDate = rollMonth(startWholePeriod, -12, d2.day);
          break;
        case EUTimePeriod.week:
          tempDate = rollDay(startWholePeriod, -7);
          break;
        case EUTimePeriod.month:
          tempDate = rollMonth(startWholePeriod, -1, d2.day);
          break;
      }
      if (!initialDrawdown.isAfter(tempDate)) {
        startWholePeriod = tempDate;
        wholePeriods++;
      } else {
        break;
      }
    }
    var factor = 0.0;
    if (wholePeriods > 0) {
      factor = wholePeriods / periodsInYear;
      operandLog.add(
        DayCountFactor.operandsToString(wholePeriods, periodsInYear),
      );
    }

    // Compute days remaining if necessary
    if (!initialDrawdown.isAfter(startWholePeriod)) {
      final numerator = actualDays(initialDrawdown, startWholePeriod);
      final startDenPeriod = rollMonth(startWholePeriod, -12);

      int denominator;
      if (numerator == 0) {
        denominator = periodsInYear;
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

enum EUTimePeriod {
  year,
  month,
  week,
}
