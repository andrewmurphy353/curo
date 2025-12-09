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
  /// Options are 'year', 'half-year', 'quarter 'month', 'fortnight',
  /// 'week', or 'day'. For mortgages, 'month' is standard.
  /// Default is 'month' if undefined.
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
    final principalOperandLog = <String>[];
    final fractionalOperandLog = <String>[];

    // Handle daily unit-periods
    if (timePeriod == DayCountTimePeriod.day) {
      final days = actualDays(initialDrawdown, startWholePeriod);
      final fractionalAdjustment = days / 365.0;
      fractionalOperandLog.add(DayCountFactor.operandsToString(days, 365));
      return DayCountFactor.usAppendixJ(
        0.0, // No whole periods for daily
        fractionalAdjustment,
        principalOperandLog,
        fractionalOperandLog,
      );
    }

    // Compute whole periods
    while (true) {
      DateTime tempDate = startWholePeriod;
      switch (timePeriod) {
        case DayCountTimePeriod.year:
          tempDate = rollMonth(startWholePeriod, -12, d2.day);
          break;
        case DayCountTimePeriod.halfYear:
          tempDate = rollMonth(startWholePeriod, -6, d2.day);
          break;
        case DayCountTimePeriod.quarter:
          tempDate = rollMonth(startWholePeriod, -3, d2.day);
          break;
        case DayCountTimePeriod.month:
          tempDate = rollMonth(startWholePeriod, -1, d2.day);
          break;
        case DayCountTimePeriod.fortnight:
          tempDate = rollDay(startWholePeriod, -14);
          break;
        case DayCountTimePeriod.week:
          tempDate = rollDay(startWholePeriod, -7);
          break;
        case DayCountTimePeriod.day:
          // Already handled above
          throw StateError('Day time period handled separately');
      }
      if (!initialDrawdown.isAfter(tempDate)) {
        startWholePeriod = tempDate;
        wholePeriods++;
      } else {
        // Adjust for month-end cases (e.g., 28th/30th/31st)
        switch (timePeriod) {
          case DayCountTimePeriod.year:
            if (initialDrawdown.month == tempDate.month &&
                initialDrawdown.day == tempDate.day) {
              break;
            }
            if (d1.month == d2.month &&
                hasMonthEndDay(d1) &&
                hasMonthEndDay(d2)) {
              // Only increment if day aligns or is end-of-month
              if (initialDrawdown.day <= tempDate.day || hasMonthEndDay(d2)) {
                startWholePeriod = initialDrawdown;
                wholePeriods++;
              }
            }
            break;
          case DayCountTimePeriod.halfYear:
          case DayCountTimePeriod.quarter:
          case DayCountTimePeriod.month:
            if (initialDrawdown.day == tempDate.day) {
              break;
            }
            if (initialDrawdown.day >= tempDate.day &&
                hasMonthEndDay(d1) &&
                hasMonthEndDay(d2)) {
              // Ensure day alignment or end-of-month
              if (initialDrawdown.day <= tempDate.day || hasMonthEndDay(d2)) {
                startWholePeriod = initialDrawdown;
                wholePeriods++;
              }
            }
            break;
          case DayCountTimePeriod.fortnight:
          case DayCountTimePeriod.week:
          case DayCountTimePeriod.day:
            break;
        }
        break;
      }
    }

    final principalFactor = wholePeriods > 0 ? wholePeriods.toDouble() : 0.0;
    if (wholePeriods > 0) {
      principalOperandLog.add(wholePeriods.toString());
    }

    // Compute odd days (fractional adjustment)
    double fractionalAdjustment = 0.0;
    if (!initialDrawdown.isAfter(startWholePeriod)) {
      final days = actualDays(initialDrawdown, startWholePeriod);
      final int denominator;
      // See Appendix J to Part 1026 (a)(b)(5) for denominator values
      switch (timePeriod) {
        case DayCountTimePeriod.year:
          denominator = 365;
          break;
        case DayCountTimePeriod.halfYear:
          denominator = 180;
          break;
        case DayCountTimePeriod.quarter:
          denominator = 90;
          break;
        case DayCountTimePeriod.month:
          denominator = 30;
          break;
        case DayCountTimePeriod.fortnight:
          denominator = 15;
          break;
        case DayCountTimePeriod.week:
          denominator = 7;
          break;
        case DayCountTimePeriod.day:
          // Already handled above
          throw StateError('Day time period handled separately');
      }

      if (days > 0) {
        fractionalAdjustment = days / denominator;
        fractionalOperandLog.add(
          DayCountFactor.operandsToString(days, denominator),
        );
      }
    }

    return DayCountFactor.usAppendixJ(
      principalFactor,
      fractionalAdjustment,
      principalOperandLog,
      fractionalOperandLog,
    );
  }
}
