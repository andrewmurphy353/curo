import '../../curo.dart';

/// The U.S. Regulation Z, Appendix J (Federal Calendar) day count convention,
/// used for calculating the Annual Percentage Rate (APR) for closed-end credit
/// transactions, such as mortgages, under the Truth in Lending Act (TILA).
///
/// The rules for measuring time intervals are defined in Appendix J,
/// Paragraph (b)(3), treating months as equal, using a 30-day divisor for
/// odd days in monthly periods, and a 365-day year for daily periods.
///
/// See: https://www.ecfr.gov/current/title-12/chapter-X/part-1026/appendix-Appendix%20J%20to%20Part%201026
///
class USAppendixJ extends Convention {
  final DayCountTimePeriod timePeriod;

  /// Provides an instance of the Appendix J day count convention for
  /// calculating the APR for U.S. consumer credit transactions.
  ///
  /// [timePeriod] the interval between dates used in the calculation.
  /// Options are 'year', 'month', 'week', or 'day'. For mortgages,
  /// 'month' is standard. Default is 'month' if undefined.
  const USAppendixJ({
    this.timePeriod = DayCountTimePeriod.month,
  }) : super(
          usePostDates: true,
          includeNonFinancingFlows: true,
          useXirrMethod: true,
        );

  @override
  DayCountFactor computeFactor(DateTime d1, DateTime d2) {
    var wholePeriods = 0;
    final initialDrawdown = utcDate(d1);
    var startWholePeriod = utcDate(d2);
    final operandLog = <String>[];

    // Handle daily unit-periods
    if (timePeriod == DayCountTimePeriod.day) {
      final days = actualDays(initialDrawdown, startWholePeriod);
      final factor = days / 365.0;
      operandLog.add(DayCountFactor.operandsToString(days, 365));
      return DayCountFactor(factor, operandLog);
    }

    // Compute whole periods
    while (true) {
      DateTime tempDate = startWholePeriod;
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
        case DayCountTimePeriod.day:
          // Already handled above, should not reach here
          throw StateError('Day time period handled separately');
      }
      if (!initialDrawdown.isAfter(tempDate)) {
        startWholePeriod = tempDate;
        wholePeriods++;
      } else {
        // Handle month-end cases (e.g., February 28/29 for 30th/31st)
        switch (timePeriod) {
          case DayCountTimePeriod.year:
            if (initialDrawdown.month == tempDate.month &&
                initialDrawdown.day == tempDate.day) {
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
            break;
          case DayCountTimePeriod.day:
            break;
        }
        break;
      }
    }

    double principalFactor = 0.0;
    if (wholePeriods > 0) {
      principalFactor = wholePeriods.toDouble();
      operandLog.add(wholePeriods.toString());
    }

    // Compute odd days
    double fractionalAdjustment = 0.0;
    if (!initialDrawdown.isAfter(startWholePeriod)) {
      final days = actualDays(initialDrawdown, startWholePeriod);
      var denominator = timePeriod == DayCountTimePeriod.month
          ? 30
          : actualDays(rollMonth(startWholePeriod, -12), startWholePeriod);
      if (days == 0) {
        denominator = timePeriod.periodsInYear;
      }
      fractionalAdjustment += days / denominator;

      if (days > 0 || operandLog.isEmpty) {
        operandLog.add(
          DayCountFactor.operandsToString(days, denominator),
        );
      }
    }
    return DayCountFactor.usAppendixJ(
      principalFactor,
      fractionalAdjustment,
      operandLog,
    );
  }
}
