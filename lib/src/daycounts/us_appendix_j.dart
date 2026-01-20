import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/enums.dart';
import 'package:curo/src/utils.dart';

/// Implements the US Regulation Z, Appendix J day count convention for
/// Annual Percentage Rate (APR).
///
/// Used for closed-end credit transactions (e.g., mortgages) under the
/// Truth in Lending Act (TILA).
///
/// Time intervals are measured **backward** from the cash flow date to
/// the initial drawdown, expressed as:
/// - `t`: Whole unit-periods (e.g., months, years)
/// - `f`: Fractional adjustment for odd days (e.g., 5/30)
/// - `p`: Number of periods per year
///
/// Special handling:
/// - Daily periods bypass whole-period loop (direct actual days / 365)
/// - Month-end alignment when cash flow date is month-end
/// - Preferred day = 31 for month-end dates to preserve EOM
///
/// See: https://www.ecfr.gov/current/title-12/chapter-X/part-1026/appendix-Appendix%20J%20to%20Part%201026
class USAppendixJ extends Convention {
  final DayCountTimePeriod timePeriod;

  const USAppendixJ({this.timePeriod = DayCountTimePeriod.month})
      : super(
          usePostDates: true,
          includeNonFinancingFlows: true,
          useXirrMethod: true,
        );

  @override
  DayCountFactor computeFactor(DateTime start, DateTime end) {
    if (end.isBefore(start)) {
      throw ArgumentError('end must not be before start');
    }
    if (start == end) {
      return DayCountFactor(
        primaryPeriodFraction: 0.0,
        partialPeriodFraction: 0.0,
        discountTermsLog: ['t = 0', 'f = 0', 'p = ${timePeriod.periodsInYear}'],
      );
    }

    final initialDrawdown = normalizeToMidnightUtc(start);
    final cashFlowDate = normalizeToMidnightUtc(end);

    var wholePeriods = 0;
    var startWholePeriod = cashFlowDate;

    // Special case: daily period — no whole periods, direct fractional
    if (timePeriod == DayCountTimePeriod.day) {
      final days = actualDays(initialDrawdown, cashFlowDate);
      final f = days / 365.0;
      final fLog =
          days > 0 ? '$days/365 = ${gaussRound(f, 8).toStringAsFixed(8)}' : '0';

      return DayCountFactor(
        primaryPeriodFraction: 0.0,
        partialPeriodFraction: f,
        discountTermsLog: ['t = 0', 'f = $fLog', 'p = 365'],
      );
    }

    // Determine preferred day for rolling
    var preferredDay = cashFlowDate.day;
    if (hasMonthEndDay(cashFlowDate)) {
      preferredDay = 31; // Force last day of month
    }

    // Count whole periods backward
    while (true) {
      final tempDate = switch (timePeriod) {
        DayCountTimePeriod.year => rollMonth(
            startWholePeriod,
            -12,
            preferredDay,
          ),
        DayCountTimePeriod.halfYear => rollMonth(
            startWholePeriod,
            -6,
            preferredDay,
          ),
        DayCountTimePeriod.quarter => rollMonth(
            startWholePeriod,
            -3,
            preferredDay,
          ),
        DayCountTimePeriod.month => rollMonth(
            startWholePeriod,
            -1,
            preferredDay,
          ),
        DayCountTimePeriod.fortnight => rollDay(startWholePeriod, -14),
        DayCountTimePeriod.week => rollDay(startWholePeriod, -7),
        _ =>
          throw StateError('Unsupported time period'), // coverage:ignore-line
      };

      if (tempDate.isBefore(initialDrawdown)) {
        break;
      }

      startWholePeriod = tempDate;
      wholePeriods++;
    }

    final t = wholePeriods.toDouble();
    final tLog = wholePeriods > 0 ? '$wholePeriods' : '0';

    // Odd days (fractional part)
    double f = 0.0;
    String fLog = '0';

    if (!initialDrawdown.isAfter(startWholePeriod)) {
      final days = actualDays(initialDrawdown, startWholePeriod);

      if (days > 0) {
        final denominator = switch (timePeriod) {
          DayCountTimePeriod.year => 365,
          DayCountTimePeriod.halfYear => 180,
          DayCountTimePeriod.quarter => 90,
          DayCountTimePeriod.month => 30,
          DayCountTimePeriod.fortnight => 15,
          DayCountTimePeriod.week => 7,
          _ =>
            throw StateError('Unsupported time period'), // coverage:ignore-line
        };

        f = days / denominator;
        fLog = '$days/$denominator = ${gaussRound(f, 8).toStringAsFixed(8)}';
      }
    }

    final p = timePeriod.periodsInYear;

    return DayCountFactor(
      primaryPeriodFraction: t,
      partialPeriodFraction: f,
      discountTermsLog: ['t = $tLog', 'f = $fLog', 'p = $p'],
    );
  }
}
