import '../utilities/dates.dart';
import 'convention.dart';
import 'day_count_factor.dart';

/// The Actual/365 day count convention which specifies that the number of
/// days in the Calculation Period or Compounding Period in respect of which
/// payment is being made is divided by 365.
///
/// This convention is also known as "Act/365 Fixed"
class Act365 extends Convention {
  /// Provides an instance of the Act/365 day count convention object.
  ///
  /// The default day count instance is suitable for use in all compound
  /// interest calculations. With the default setup interest is calculated
  /// on the reducing capital balance and is compounded at a frequency
  /// typically determined by the time interval between cash flows.
  ///
  /// For non-compound interest calculations, such as solving for unknowns
  /// on the basis of an eXtended Internal Rate of Return (XIRR), set
  /// [useXirrMethod] to *true*. With this setup the day count is calculated
  /// with reference to the first cash flow date in the series, which is
  /// how the Microsoft Excel XIRR function works.
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
  const Act365({
    super.usePostDates = true,
    super.includeNonFinancingFlows = false,
    super.useXirrMethod = false,
  });

  @override
  DayCountFactor computeFactor(DateTime d1, DateTime d2) {
    final int numerator = actualDays(d1, d2);
    final double factor = numerator / 365;
    return DayCountFactor(
      factor,
      [DayCountFactor.operandsToString(numerator, 365)],
    );
  }
}
