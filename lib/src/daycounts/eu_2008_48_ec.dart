import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/enums.dart';
import 'package:curo/src/utils.dart';
import 'package:meta/meta.dart';

/// Implements the EU Directive 2008/48/EC day count convention for Annual Percentage
/// Rate of Charge (APRC).
///
/// Used for consumer credit agreements in EU member states. Time intervals are
/// calculated **backwards** from the cash flow date to the initial drawdown
/// date, expressed as:
/// - Whole periods (years, months, or weeks)
/// - Plus remaining days divided by 365 (or 366 if 12-month period prior to
///   drawdown date includes leap day)
///
/// Reference: EU APR Guidelines (ANNEX 1, section 4.1.1]. This document is no
/// longer available online and is provided here (./docs/assets/reference/) for
/// reference.
///
class EU200848EC extends Convention {
  final DayCountTimePeriod timePeriod;

  EU200848EC({this.timePeriod = DayCountTimePeriod.month})
      : super(
          usePostDates: true,
          includeNonFinancingFlows: true,
          useXirrMethod: true,
        ) {
    if (!const [
      DayCountTimePeriod.year,
      DayCountTimePeriod.month,
      DayCountTimePeriod.week,
    ].contains(timePeriod)) {
      throw ArgumentError(
        'EU200848EC only supports year, month, and week time periods',
      );
    }
  }

  @override
  DayCountFactor computeFactor(DateTime start, DateTime end) {
    if (end.isBefore(start)) {
      throw ArgumentError('end must not be before start');
    }
    if (start == end) {
      return const DayCountFactor(
        primaryPeriodFraction: 0.0,
        discountFactorLog: ['0'],
      );
    }

    final initialDrawdown = normalizeToMidnightUtc(start);
    var startWholePeriod = normalizeToMidnightUtc(end);

    var wholePeriods = 0;
    final operandLog = <String>[];

    int preferredDay = startWholePeriod.day;
    if (hasMonthEndDay(startWholePeriod)) {
      preferredDay = 31; // Force last day of month
    }

    // Whole periods
    while (true) {
      final tempDate = switch (timePeriod) {
        DayCountTimePeriod.year => rollMonth(
            startWholePeriod,
            -12,
            preferredDay,
          ),
        DayCountTimePeriod.month => rollMonth(
            startWholePeriod,
            -1,
            preferredDay,
          ),
        DayCountTimePeriod.week => rollDay(startWholePeriod, -7),
        _ => throw StateError('Unsupported time period'),
      };

      if (tempDate.isBefore(initialDrawdown)) {
        break;
      }

      startWholePeriod = tempDate;
      wholePeriods++;
    }

    var factor = 0.0;
    if (wholePeriods > 0) {
      factor = wholePeriods / timePeriod.periodsInYear;
      operandLog.add('$wholePeriods/${timePeriod.periodsInYear}');
    }

    // Fractional days
    if (!initialDrawdown.isAfter(startWholePeriod)) {
      final numerator = actualDays(initialDrawdown, startWholePeriod);

      int denominator;
      if (numerator == 0) {
        denominator = timePeriod.periodsInYear;
      } else {
        // Denominator is number of days in year prior to drawdown
        final startDenPeriod = rollMonth(
          startWholePeriod,
          -12,
          startWholePeriod.day,
        );
        denominator = actualDays(startDenPeriod, startWholePeriod);
      }

      factor += numerator / denominator.toDouble();

      if (numerator > 0 || operandLog.isEmpty) {
        operandLog.add('$numerator/$denominator');
      }
    }

    return DayCountFactor(
      primaryPeriodFraction: factor,
      discountFactorLog: operandLog,
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Testing utilities — not part of public API

  @visibleForTesting
  EU200848EC.testOnly({required this.timePeriod})
      : super(
          usePostDates: true,
          includeNonFinancingFlows: true,
          useXirrMethod: true,
        );
}
