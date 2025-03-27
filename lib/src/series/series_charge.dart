import 'frequency.dart';
import 'mode.dart';
import 'series.dart';

/// A series of one or more charges or fees received by a lender. These are
/// non-financing cash flows which are excluded from the computation of
/// unknown advance or payment cash flow values, but are included under
/// certain circumstances in other calculations for instance the computation
/// of implicit interest rates such as Annual Percantage Rates (APRs),
/// as documented elsewhere.
class SeriesCharge extends Series {
  ///
  /// [numberOf] The total number of charges in the series. Default is 1.
  ///
  /// [frequency] The compounding frequency of recurring payments in
  /// the series.
  ///
  /// [label] A localised label in singular form to assign to each
  /// cash flow in the series e.g. 'Arrangement fee' (not 'Arrangement fees').
  /// The label is useful for annotating the payment cash flows listed in
  /// an amortisation schedule or calculation proof.
  ///
  /// [value] The value of the one or more charges in the series (required
  /// input).
  ///
  /// [postDateFrom] The post or due date of the first charge in
  /// the series. Subsequent charge due dates are determined with
  /// reference to this date *and* the offset of the interval defined by the
  /// series frequency. If the date is not defined it will be computed
  /// with reference to the current system date or the end date of a
  /// preceding charge series.
  ///
  /// [mode] The advance or arrear mode of recurring charges in the series.
  ///
  SeriesCharge({
    super.numberOf = 1,
    super.frequency = Frequency.monthly,
    String? label,
    required double super.value,
    super.postDateFrom,
    super.mode = Mode.advance,
  }) : super(
          label: label ?? '',
          valueDateFrom: postDateFrom,
        );

  SeriesCharge copyWith({
    int? numberOf,
    Frequency? frequency,
    String? label,
    double? value,
    DateTime? postDateFrom,
    Mode? mode,
  }) =>
      SeriesCharge(
        numberOf: numberOf ?? this.numberOf,
        frequency: frequency ?? this.frequency,
        label: label ?? this.label,
        value: value ?? this.value!,
        postDateFrom: postDateFrom ?? this.postDateFrom,
        mode: mode ?? this.mode,
      );

  // coverage:ignore-start
  @override
  String toString() {
    final sb = StringBuffer();
    sb.write('\nSeriesCharge [');
    sb.write('numberOf: $numberOf, ');
    sb.write('frequency: $frequency, ');
    sb.write('label: $label, ');
    sb.write('value: $value, ');
    sb.write('postDateFrom: $postDateFrom, ');
    sb.write('mode: $mode, ');
    sb.write(']');
    return sb.toString();
  }
  // coverage:ignore-end
}
