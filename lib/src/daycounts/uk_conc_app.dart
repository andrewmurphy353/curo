import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/enums.dart';
import 'package:curo/src/utils.dart';

/// Implements the UK CONC App day count convention for Annual Percentage Rate
/// of Charge (APRC).
///
/// Used in the United Kingdom under the Financial Services and
/// Markets Act 2000 (FSMA 2000) for consumer credit agreements.
///
/// Supports two contexts:
/// - Secured on land ([isSecuredOnLand] = true): CONC App 1.1 (mortgages)
/// - Not secured on land ([isSecuredOnLand] = false): CONC App 1.2 (other
///   credit)
///
/// Time intervals are calculated **forward** from the initial drawdown date.
/// Whole periods (months or weeks) are preferred when exact. For secured
/// single-payment agreements, months take precedence when both months and
/// weeks fit exactly.
///
/// Residual days are divided by 365 (or 366 in leap years).
///
/// See:
/// - CONC App 1.1: https://www.handbook.fca.org.uk/handbook/CONC/App/1/1.html
/// - CONC App 1.2: https://www.handbook.fca.org.uk/handbook/CONC/App/1/2.html
///
class UKConcApp extends Convention {
  final bool isSecuredOnLand;
  final bool hasSinglePayment;
  final DayCountTimePeriod timePeriod;

  /// Creates a UK CONC App day count convention.
  ///
  /// [isSecuredOnLand]: True for agreements secured on land (CONC App 1.1).
  ///
  /// [hasSinglePayment]: True if the profile has only one repayment (forces
  ///   month preference for whole periods when secured).
  ///
  /// [timePeriod]: Repayment frequency. Must be [DayCountTimePeriod.month]
  ///   or [DayCountTimePeriod.week]. Defaults to [DayCountTimePeriod.month].
  UKConcApp({
    this.isSecuredOnLand = false,
    this.hasSinglePayment = false,
    this.timePeriod = DayCountTimePeriod.month,
  }) : super(
         usePostDates: true,
         includeNonFinancingFlows: true,
         useXirrMethod: true,
       ) {
    if (timePeriod != DayCountTimePeriod.month &&
        timePeriod != DayCountTimePeriod.week) {
      throw ArgumentError(
        'UKConcApp only supports month and week time periods',
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

    final d1 = normalizeToMidnightUtc(start); // initial drawdown
    final d2 = normalizeToMidnightUtc(end); // cash flow date

    final operandLog = <String>[];
    var factor = 0.0;
    var wholePeriods = 0;

    // Determine preferred period (month takes precedence in secured
    // single-repayment)
    final useMonths =
        timePeriod == DayCountTimePeriod.month ||
        (isSecuredOnLand && hasSinglePayment);

    if (useMonths) {
      wholePeriods = _countWholeMonths(d1, d2);
    } else {
      wholePeriods = _countWholeWeeks(d1, d2);
    }

    if (wholePeriods > 0) {
      final denominator = (useMonths || (isSecuredOnLand && hasSinglePayment))
          ? 12
          : 52;
      factor = wholePeriods / denominator;
      operandLog.add('$wholePeriods/$denominator');
    }

    // Compute end of whole period
    final wholePeriodEnd =
        useMonths || (isSecuredOnLand && hasSinglePayment && wholePeriods > 0)
        ? rollMonth(d1, wholePeriods, d1.day)
        : rollDay(d1, wholePeriods * 7);

    // Residual days (may cross year boundary)
    if (wholePeriodEnd.isBefore(d2) || wholePeriodEnd == d2) {
      factor = _processRemainingDays(d2, wholePeriodEnd, factor, operandLog);
    }

    return DayCountFactor(
      primaryPeriodFraction: factor,
      discountFactorLog: operandLog,
    );
  }

  int _countWholeMonths(DateTime d1, DateTime d2) {
    var months = 0;
    var current = d1;
    while (true) {
      final next = rollMonth(current, 1, d1.day);
      if (next.isAfter(d2)) break;
      current = next;
      months++;
    }
    return months;
  }

  int _countWholeWeeks(DateTime d1, DateTime d2) {
    final days = actualDays(d1, d2);
    return days ~/ 7;
  }

  double _processRemainingDays(
    DateTime end,
    DateTime wholePeriodEnd,
    double factor,
    List<String> operandLog,
  ) {
    if (wholePeriodEnd.year == end.year) {
      final daysRemaining = end.difference(wholePeriodEnd).inDays;
      if (daysRemaining > 0) {
        final daysInYear = isLeapYear(end.year) ? 366 : 365;
        factor += daysRemaining / daysInYear;
        operandLog.add('$daysRemaining/$daysInYear');
      }
      // else: no residual -> add nothing
    } else {
      // Remaining to year end
      final yearEnd = DateTime.utc(wholePeriodEnd.year, 12, 31);
      var daysRemaining = yearEnd.difference(wholePeriodEnd).inDays;
      if (daysRemaining > 0) {
        final daysInYear = isLeapYear(wholePeriodEnd.year) ? 366 : 365;
        factor += daysRemaining / daysInYear;
        operandLog.add('$daysRemaining/$daysInYear');
      }

      // From Jan 1 to end
      final jan1Next = yearEnd.add(const Duration(days: 1));
      daysRemaining = end.difference(jan1Next).inDays;
      if (daysRemaining > 0) {
        final daysInYear = isLeapYear(end.year) ? 366 : 365;
        factor += daysRemaining / daysInYear;
        operandLog.add('$daysRemaining/$daysInYear');
      }
    }
    return factor;
  }
}
