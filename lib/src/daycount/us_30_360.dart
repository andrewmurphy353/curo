import 'convention.dart';
import 'day_count_factor.dart';

/// The 30/360 (US) day count convention which specifies that the number
/// of days in the Calculation Period or Compounding Period in respect of
/// which payment is being made is divided by 360, calculated on a formula
/// basis as follows:
///
/// > Day Count Fraction =
///   \[\[360 ∗ (YY2 − YY1)\] + \[30 ∗ (MM2 − MM1)\] + (DD2 − DD1)\] / 360
///
/// where:
///
/// * "Y1" is the year, expressed as a number, in which the first day of
/// the Calculation or Compounding Period falls;
/// * "Y2" is the year, expressed as a number, in which the day immediately
/// following the last day included in the Calculation Period or Compounding
/// Period falls;
/// * "M1" is the calendar month, expressed as a number, in which the first
/// day of the Calculation Period or Compounding Period falls;
/// * "M2" is the calendar month, expressed as a number, in which the day
/// immediately following the last day included in the Calculation Period
/// or Compounding Period falls;
/// * "D1" is the first calendar day, expressed as number, of the Calculation
/// Period or Compounding Period, unless such number would be 31, in which
/// case D1 will be 30; and
/// * "D2" is the calendar day, expressed as a number, immediately following
/// the last day included in the Calculation Period or Compounding Period,
/// unless such number would be 31 and D1 is greater than 29, in which
/// case D2 will be 30.
///
/// This convention is also known as "Bond_Basis_30360", "30/360", "360/360"
/// or "Bond Basis"
class US30360 extends Convention {
  /// Provides an instance of the 30/360 (US) day count convention object.
  ///
  /// The default day count instance is suitable for use in all compound
  /// interest calculations. With the default setup interest is calculated
  /// on the reducing capital balance and is compounded at a frequency
  /// typically determined by the time interval between cash flows.
  ///
  /// For non-compound interest calculations, such as solving for unknowns
  /// on the basis of an eXtended Internal Rate of Return (XIRR), set the
  /// [useXirrMethod] to *true*. With this setup the day count is calculated
  /// with reference to the first cash flow date in the series, in much the
  /// same way as the Microsoft Excel XIRR function does \[1\].
  ///
  /// \[1\] The XIRR function in Excel computes time intervals between the
  /// first and subsequent cash flow dates using *actual days*, whereas
  /// this implementation offers the flexibility to determine those time
  /// intervals on a 30/360 day basis.
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
  const US30360({
    super.usePostDates = true,
    super.includeNonFinancingFlows = false,
    super.useXirrMethod = false,
  });

  @override
  DayCountFactor computeFactor(DateTime d1, DateTime d2) {
    final dd1 = d1.day;
    final mm1 = d1.month;
    final yyyy1 = d1.year;
    final dd2 = d2.day;
    final mm2 = d2.month;
    final yyyy2 = d2.year;

    var z = 0;
    if (dd1 == 31) {
      z = 30;
    } else {
      z = dd1;
    }
    final dt1 = 360 * yyyy1 + 30 * mm1 + z;

    if (dd2 == 31 && (dd1 == 30 || dd1 == 31)) {
      z = 30;
    } else if (dd2 == 31 && dd1 < 30) {
      z = dd2;
    } else {
      // dd2 < 31
      z = dd2;
    }
    final dt2 = 360 * yyyy2 + 30 * mm2 + z;

    final numerator = (dt2 - dt1).abs();
    final factor = numerator / 360;

    return DayCountFactor(
      factor,
      [DayCountFactor.operandsToString(numerator, 360)],
    );
  }
}
