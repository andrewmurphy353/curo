import 'day_count_factor.dart';
import 'day_count_origin.dart';

/// Defines the contract for day count convention concrete implementations.
///
abstract class Convention {
  /// Defines whether the days counted between cash flows are computed
  /// using cash flow post dates (true), or cash flow value dates (false).
  ///
  /// Post dates should generally be used by default.
  ///
  /// Value dates are used in limited cases, for example to determine a
  /// lender's Internal Rate of Return (IRR) where the settlement of cash
  /// advances is deferred in 0% and low interest rate promotions
  /// underwritten for third-party equipment suppliers.
  final bool usePostDates;

  /// Determines whether non-financing cash flows, such as charges or
  /// fees, within a cash flow profile are to be included in the computation
  /// of periodic factors.
  ///
  /// Generally speaking non-financing cash flows should be excluded (false)
  /// when solving for unknown financing cash flow values or interest rates.
  ///
  /// In limited circumstances however it may be necessary to include
  /// non-financing cash flows (true), for example in the European Union
  /// where consumer credit legislation requires the inclusion of certain
  /// associated charges in the calculation of the Annual Percentage Rate
  /// of Charge (APRC). In such cases it is important that the cash flow
  /// profile only incorporates those charges which are required to be
  /// included in the APR calculation.
  final bool includeNonFinancingFlows;

  /// Determines whether to use the XIRR method of determining time periods
  /// between cash flow dates (true).
  final bool useXirrMethod;

  const Convention({
    required this.usePostDates,
    required this.includeNonFinancingFlows,
    required this.useXirrMethod,
  });

  DayCountOrigin dayCountOrigin() {
    if (useXirrMethod) {
      return DayCountOrigin.drawdown;
    }
    return DayCountOrigin.neighbour;
  }

  /// Computes the periodic factor for a given day count convention.
  ///
  /// [d1] the earlier of two dates
  /// [d2] the later of two dates
  DayCountFactor computeFactor(DateTime d1, DateTime d2);

  // coverage:ignore-start
  @override
  String toString() {
    final sb = StringBuffer();
    sb.write(runtimeType);
    sb.write('[');
    sb.write('usePostDates:$usePostDates, ');
    sb.write('includeNonFinancingFlows:$includeNonFinancingFlows, ');
    sb.write('useXirrMethod:$useXirrMethod');
    sb.write(']');
    return sb.toString();
  }
  // coverage:ignore-end
}
