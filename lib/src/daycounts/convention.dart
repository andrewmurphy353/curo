export 'actual_360.dart';
export 'actual_365.dart';
export 'actual_isda.dart';
export 'day_count_factor.dart';
export 'eu_30_360.dart';
export 'eu_2008_48_ec.dart';
export 'uk_conc_app.dart';
export 'us_30_360.dart';
export 'us_30u_360.dart';
export 'us_appendix_j.dart';

import 'package:curo/src/enums.dart';
import 'package:curo/src/daycounts/day_count_factor.dart';

/// Abstract base class for day count conventions in financial calculations.
///
/// Day count conventions compute the fraction of a year between two dates,
/// used in interest calculations such as APR, XIRR, or effective rate solving.
///
/// Subclasses must implement [computeFactor].
///
abstract class Convention {
  /// If true, uses cash flow post dates for day counts.
  /// If false, uses value dates.
  ///
  /// Value dates are typically used in IRR calculations involving deferred
  /// settlement (e.g., 0% interest promotions for third-party suppliers).
  /// Post dates are the default for most consumer credit scenarios.
  final bool usePostDates;

  /// If true, includes non-financing cash flows (e.g., fees, charges)
  /// in periodic factor computations.
  ///
  /// Generally false, but required to be true in certain jurisdictions
  /// (e.g., EU consumer credit laws for APRC) where specific charges
  /// must be included in the total cost of credit.
  final bool includeNonFinancingFlows;

  /// If true, uses the XIRR-style method: all time periods measured from
  /// the initial drawdown (origin = DRAWDOWN).
  /// If false, time periods are measured between neighboring cash flows
  /// (origin = NEIGHBOUR).
  final bool useXirrMethod;

  const Convention({
    this.usePostDates = false,
    this.includeNonFinancingFlows = false,
    this.useXirrMethod = false,
  });

  /// Determines the origin for day count calculations.
  ///
  /// Returns [DayCountOrigin.drawdown] if [useXirrMethod] is true,
  /// otherwise [DayCountOrigin.neighbour].
  DayCountOrigin get dayCountOrigin =>
      useXirrMethod ? DayCountOrigin.drawdown : DayCountOrigin.neighbour;

  /// Computes the day count factor between two dates.
  ///
  /// [start] The earlier date.
  /// [end]   The later date.
  ///
  /// Returns a [DayCountFactor] representing the year fraction and
  /// any convention-specific operand log.
  DayCountFactor computeFactor(DateTime start, DateTime end);

  @override
  String toString() => '$runtimeType['
      'usePostDates: $usePostDates, '
      'includeNonFinancingFlows: $includeNonFinancingFlows, '
      'useXirrMethod: $useXirrMethod'
      ']';
}
